extends Node
class_name DashComponent

signal dash_started
signal dash_ended
signal charge_started
signal charge_ended
signal dash_cooldown_finished

@export_group("Dash Settings")
@export var dash_speed: float = 1800.0
@export var min_dash_duration: float = 0.12
@export var max_dash_duration: float = 0.5

@export_group("Charge Settings")
@export var max_charge_time: float = 3.0

@export_group("Cooldown")
@export var dash_cooldown: float = 0.3

var dash_timer: float = 0.0
var charge_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

var body: CharacterBody2D
var movement_component: MovementComponent
var health_component: HealthComponent


func _ready():
	body = get_parent().get_parent()
	if not body is CharacterBody2D:
		push_error("DashComponent must be a child of a CharacterBody2D")
		queue_free()
		return
		
	movement_component = body.get_node_or_null("Components/MovementComponent")
	health_component = body.get_node_or_null("Components/HealthComponent")
	if movement_component == null:
		push_error("MovementComponent not found on parent node.")

func _input(event: InputEvent) -> void:
	# Проверяем, можно ли начать зарядку, и НАЖАТА ли кнопка "dash"
	if event.is_action_pressed("dash") and can_charge():
		start_charging()
		get_viewport().set_input_as_handled()

	# Проверяем, ОТПУЩЕНА ли кнопка "dash" во время зарядки
	elif is_charging() and event.is_action_released("dash"):
		print('dashing')
		end_charging()
		start_dash()
		get_viewport().set_input_as_handled()

func handle(delta: float) -> void:
	# 1. Обновляем кулдаун
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)
		if dash_cooldown_timer == 0.0:
			dash_cooldown_finished.emit()
	
	# 2. Обновляем активный рывок
	if is_dashing():
		update_active_dash(delta)
		
	# 3. Обновляем таймер зарядки (если она идет)
	elif is_charging():
		charge_timer = min(charge_timer + delta, max_charge_time)

func update_active_dash(delta: float):
	dash_timer -= delta
	body.velocity = dash_direction * dash_speed
	if dash_timer <= 0.0:
		end_dash()

func start_charging():
	print('start')
	body.state = types.PlayerState.CHARGING_DASH
	charge_timer = 0.0
	if is_instance_valid(movement_component) and movement_component.has_method("set_active"):
		movement_component.set_active(false)
	charge_started.emit()

func end_charging():
	body.state = types.PlayerState.IDLE
	charge_ended.emit()

func start_dash() -> void:
	if not is_instance_valid(body): return
		
	var input_direction = Vector2.ZERO
	if is_instance_valid(movement_component):
		input_direction = movement_component.get_input_vector()
	
	if input_direction == Vector2.ZERO:
		if body.velocity.length_squared() > 0:
			input_direction = body.velocity.normalized()
		else:
			input_direction = Vector2.RIGHT
	
	body.state = types.PlayerState.DASH
	
	var charge_ratio = charge_timer / max_charge_time
	var current_dash_duration = lerp(min_dash_duration, max_dash_duration, charge_ratio)
	
	dash_timer = current_dash_duration
	dash_cooldown_timer = dash_cooldown
	dash_direction = input_direction.normalized()
	
	dash_started.emit()

func end_dash() -> void:
	body.state = types.PlayerState.IDLE
	charge_timer = 0.0
	body.velocity = Vector2.ZERO
	if is_instance_valid(movement_component) and movement_component.has_method("set_active"):
		movement_component.set_active(true)
	dash_ended.emit()

func can_charge() -> bool:
	return !is_dashing() and !is_charging() and dash_cooldown_timer <= 0.0

func get_charge_progress() -> float:
	if not is_charging(): return 0.0
	return charge_timer / max_charge_time

func get_dash_cooldown_progress() -> float:
	if dash_cooldown <= 0: return 1.0
	return 1.0 - (dash_cooldown_timer / dash_cooldown)

func is_charging() -> bool:
	return body.state == types.PlayerState.CHARGING_DASH or body.state == types.PlayerState.CHARGING_DASH_AND_ATTACK

func is_dashing() -> bool:
	return body.state == types.PlayerState.DASH or body.state == types.PlayerState.CHARGING_ATTACK_AND_DASHING
