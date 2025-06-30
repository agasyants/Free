extends Node
class_name MeleeAttackComponent

## Компонент ближнего боя (ПРОСТАЯ ВЕРСИЯ).
## Использует _input(event) для мгновенной реакции на ввод.

# --- Сигналы ---
signal attack_started
signal attack_ended
signal charge_started
signal charge_ended

# --- Параметры ---
@export_group("Attack Settings")
@export var quick_attack_damage: float = 25.0
@export var charged_attack_damage: float = 75.0
@export var attack_range: float = 100.0

@export_group("Timing")
@export var hold_threshold: float = 0.2
@export var max_charge_time: float = 2.0
@export var attack_cooldown: float = 0.3

# --- Состояния ---
var is_hold_timing: bool = false
var hold_timer: float = 0.0
var charge_timer: float = 0.0
var cooldown_timer: float = 0.0

# --- Ссылки ---
var body: CharacterBody2D
var movement_component: MovementComponent

func _ready():
	body = get_parent().get_parent()
	if not body is CharacterBody2D:
		push_error("MeleeAttackComponent must be a child of a CharacterBody2D")
		queue_free()
		return
		
	movement_component = body.get_node_or_null("Components/MovementComponent")

func _input(event: InputEvent) -> void:
	if can_attack() and event.is_action_pressed("attack"):
		start_hold_timing()
		get_viewport().set_input_as_handled()

	elif event.is_action_released("attack"):
		if is_hold_timing:
			end_hold_timing()
			execute_quick_attack()
		elif is_charging():
			end_charging()
			execute_charged_attack()
		get_viewport().set_input_as_handled()

## Эту функцию нужно вызывать из _physics_process родителя.
func handle(delta: float) -> void:
	# Обновляем кулдаун
	if cooldown_timer > 0.0:
		cooldown_timer = max(0.0, cooldown_timer - delta)
	
	# Проверяем переход от удержания к зарядке
	if is_hold_timing:
		hold_timer += delta
		if hold_timer >= hold_threshold:
			end_hold_timing()
			start_charging()
	
	# Обновляем зарядку
	elif is_charging():
		charge_timer = min(charge_timer + delta, max_charge_time)

func start_hold_timing():
	body.state = types.PlayerState.CHARGING_ATTACK
	is_hold_timing = true
	hold_timer = 0.0

func end_hold_timing():
	is_hold_timing = false
	hold_timer = 0.0

func start_charging():
	if body.state != types.PlayerState.CHARGING_ATTACK:
		body.state = types.PlayerState.CHARGING_ATTACK
	charge_timer = 0.0
	if movement_component and movement_component.has_method("set_active"):
		movement_component.set_active(false)
	charge_started.emit()

func end_charging():
	body.state = types.PlayerState.IDLE
	charge_ended.emit()

func execute_quick_attack():
	if not can_execute(): return
	
	body.state = types.PlayerState.ATTACK
	cooldown_timer = attack_cooldown
	
	perform_attack(quick_attack_damage)
	attack_started.emit()
	
	# Завершаем атаку сразу
	await get_tree().process_frame
	end_attack()

func execute_charged_attack():
	if not can_execute(): return
	
	body.state = types.PlayerState.ATTACK
	cooldown_timer = attack_cooldown
	
	var charge_ratio = charge_timer / max_charge_time
	var damage = lerp(quick_attack_damage, charged_attack_damage, charge_ratio)
	
	perform_attack(damage)
	attack_started.emit()
	
	# Завершаем атаку сразу
	await get_tree().process_frame
	end_attack()

func perform_attack(damage: float):
	var attack_direction = get_attack_direction()
	var attack_position = body.global_position + attack_direction * attack_range
	
	# Простое обнаружение врагов в радиусе
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(attack_position) <= attack_range:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)

func end_attack():
	body.state = types.PlayerState.IDLE
	charge_timer = 0.0
	if movement_component and movement_component.has_method("set_active"):
		movement_component.set_active(true)
	attack_ended.emit()

func get_attack_direction() -> Vector2:
	var input_direction = movement_component.get_input_vector()
	if input_direction != Vector2.ZERO:
		return input_direction.normalized()
	
	if body.velocity.length_squared() > 0:
		return body.velocity.normalized()
	
	return Vector2.RIGHT

func can_attack() -> bool:
	return !is_attacking() and !is_charging() and !is_hold_timing and cooldown_timer <= 0.0

func can_execute() -> bool:
	return is_instance_valid(body)

# --- Вспомогательные функции для UI ---
func get_charge_progress() -> float:
	if not is_charging(): return 0.0
	return charge_timer / max_charge_time

func get_cooldown_progress() -> float:
	if attack_cooldown <= 0: return 1.0
	return 1.0 - (cooldown_timer / attack_cooldown)

func is_attacking():
	return body.state == types.PlayerState.ATTACK

func is_charging():
	return body.state == types.PlayerState.CHARGING_DASH_AND_ATTACK or  body.state == types.PlayerState.CHARGING_ATTACK_AND_DASHING or body.state == types.PlayerState.CHARGING_ATTACK
