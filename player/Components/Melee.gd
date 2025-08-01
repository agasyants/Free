extends Area2D
class_name MeleeAttackComponent

@export var combo_window := 0.5
@export var pre_finish_window := 0.2
@export var post_combo_cooldown := 0.2
@export var charge_threshold := 0.6
@export var damage_duration := 0.1

var combo_attacks: Array[MeleeAttack] = []
var charged_attack: MeleeAttack

var current_attack: MeleeAttack = null
var charge_timer: float = 0.0
var combo_index: int = 0
var combo_timer: float = 0.0
var combo_ready: bool = false
var post_combo_timer: float = 0.0

var is_charging: bool = false

var hit_targets: Array = []

@onready var body: Player = get_parent().get_parent()
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var aim_area: Area2D = $AimArea2D
@onready var aim_shape: CollisionShape2D = $AimArea2D/CollisionShape2D

func _ready() -> void:
	combo_attacks = [
		LightSlash1.new(self),
		LightSlash2.new(self),
		LightSlash3.new(self)
	]
	charged_attack = ChargedSlash.new(self)
	connect("body_entered", _on_body_entered)
	body.get_node("Components/DashComponent").dash_ended.connect(_dash_ended)
	monitoring = false
	shape.disabled = true

	aim_shape.shape = create_cone_shape(200, 100, 3)

func _dash_ended():
	if is_charging:
		body.set_state(types.PlayerState.CHARGING_ATTACK)

func handle(delta: float) -> void:
	if current_attack != null:
		current_attack.update(delta)

		var attack_time_left = current_attack.get_time_left()

		# Окно начала следующего комбо чуть до окончания текущего
		if attack_time_left <= pre_finish_window and combo_index < combo_attacks.size():
			combo_ready = true

		# Завершение текущей атаки
		if current_attack.finished:
			_end_attack()
			return

	if is_charging:
		var mouse_pos = body.get_global_mouse_position()
		if !DisplayServer.is_touchscreen_available():
			body.animation_component.set_direction((mouse_pos - body.global_position).normalized())
		charge_timer += delta
		return

	if combo_timer > 0.0:
		combo_timer -= delta
	else:
		combo_ready = false
		combo_index = 0

	if post_combo_timer > 0.0:
		post_combo_timer -= delta

func _input(event: InputEvent) -> void:
	if not body.is_active:
		return

	if event.is_action_pressed("attack") or (event.is_action_pressed("attack_pc") and !DisplayServer.is_touchscreen_available()):
		get_viewport().set_input_as_handled()
		# Блокируем атаку, если в кулдауне после комбо
		if post_combo_timer > 0.0:
			return

		# Если можно продолжить комбо
		if combo_ready and current_attack == null and combo_index < combo_attacks.size():
			_start_attack(combo_attacks[combo_index])
			combo_index += 1
			combo_timer = combo_window
			combo_ready = false
			return

		# Если ничего не происходит — начинаем заряд
		if current_attack == null:
			_start_charge()
	
	else:
		if event.is_action_pressed("parry") or event.is_action_pressed("shoot"):
			is_charging = false

	if event.is_action_released("attack") or (event.is_action_released("attack_pc") and !DisplayServer.is_touchscreen_available()):
		if is_charging:
			_release_attack()
		charge_timer = 0.0
		get_viewport().set_input_as_handled()

func _start_charge() -> void:
	if current_attack != null or body.state == types.PlayerState.ATTACK:
		return
	is_charging = true
	charge_timer = 0.0
	body.set_state(types.PlayerState.CHARGING_ATTACK)

func _release_attack() -> void:
	if charge_timer >= charge_threshold:
		current_attack = charged_attack
		charged_attack.starting(charge_timer)
		is_charging = false
		body.set_state(types.PlayerState.ATTACK)
		_enable_damage()
	else:
		if combo_index < combo_attacks.size():
			_start_attack(combo_attacks[combo_index])
			combo_index += 1
			combo_timer = combo_window
		else:
			combo_index = 0
			post_combo_timer = post_combo_cooldown

func _start_attack(attack: MeleeAttack) -> void:
	current_attack = attack
	current_attack.start()
	body.set_state(types.PlayerState.ATTACK)
	_enable_damage()

func _end_attack() -> void:
	if current_attack:
		current_attack.cancel()
	current_attack = null
	body.set_state(types.PlayerState.IDLE)
	is_charging = false
	_disable_damage()

func _enable_damage() -> void:
	hit_targets.clear()
	monitoring = true
	shape.disabled = false

func _disable_damage() -> void:
	monitoring = false
	shape.disabled = true

func _on_body_entered(target: Node) -> void:
	if target == null or target in hit_targets:
		return
	hit_targets.append(target)
	if current_attack and current_attack.has_method("on_body_entered"):
		current_attack.on_body_entered(target)

func create_cone_shape(radius: float, angle_deg: float, segments: int = 8) -> ConvexPolygonShape2D:
	var cone = ConvexPolygonShape2D.new()
	var points: Array[Vector2] = [Vector2.ZERO]
	var half_angle = deg_to_rad(angle_deg) / 2

	for i in range(segments + 1):
		var t = i / float(segments)
		var a = -half_angle + 2.0 * half_angle * t
		points.append(Vector2(radius, 0).rotated(a))

	cone.points = points
	return cone

func get_slash_direction() -> Vector2:
	var facing_dir = body.animation_component.get_last_direction().normalized()
	var origin = global_position

	var candidates = aim_area.get_overlapping_bodies()

	var closest: Node2D = null
	var closest_angle = PI

	for e in candidates:
		if not e.is_in_group("enemies"):
			continue
		var to_e = (e.global_position - origin).normalized()
		var angle = abs(facing_dir.angle_to(to_e))
		if angle < closest_angle:
			closest_angle = angle
			closest = e
	if closest:
		return (closest.global_position - origin)
	
	return facing_dir/2
