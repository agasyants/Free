extends Node2D
class_name AnimationComponent

# Rotation
@export var rotation_speed: float = 12.0
@export var use_smooth_rotation: bool = true

# Transitions
@export var transition_speed: float = 10.0

# Blink
@export var blink_duration: float = 0.1
var is_blinking := false
var blink_timer := 0.0
var blink_total := 0.0
var blink_visible := true

# Directions
var target_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.RIGHT

# Animations
var animations: Dictionary = {}
var current_id: String = ""
var previous_id: String = ""
var transition: float = 0.0

# State
var damaged := false
var damage_duration = 0.2
var damage_timer = 0.0
var current_opacity := 1.0
var previous_opacity := 0.0

# Nodes
@onready var body: CharacterBody2D = get_parent().get_parent()

func _ready():
	register_animation("IDLE", IdleAnimation.new(body))
	register_animation("DASH", DashAnimation.new(body))
	register_animation("CHARGING_DASH", ChargingDashAnimation.new(body))
	register_animation("CHARGING_ATTACK", ChargingAttackAnimation.new(body))
	register_animation("SHOOT", ShootAnimation.new(body))
	register_animation("PARRY", ParryAnimation.new(body))
	register_animation("ATTACK_1", LightSlashAnimation1.new(body))
	register_animation("ATTACK_2", LightSlashAnimation1.new(body))
	register_animation("ATTACK_3", LightSlashAnimation2.new(body))
	register_animation("CHARGED_ATTACK", ChargedSlashAnimation.new(body))
	play("IDLE")  # или "DASH" для теста

# Registering
func register_animation(anim_id: String, animation: PlayerAnimation) -> void:
	animations[anim_id] = animation

func play(anim_id: String) -> void:
	if anim_id != current_id:
		previous_id = current_id
		current_id = anim_id
		transition = types.state_accelerations[body.state]*3
		animations[current_id].reset()

# External state
func set_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		target_direction = direction
		last_direction = direction

func rotate_to_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		body.rotation = direction.angle()
		last_direction = direction

func stop_rotation() -> void:
	target_direction = Vector2.ZERO

func get_current_direction() -> Vector2:
	return Vector2.from_angle(body.rotation)

func get_last_direction() -> Vector2:
	return last_direction

func set_damaged() -> void:
	damaged = true
	damage_timer = damage_duration

# Blink logic
func start_blink(duration: float) -> void:
	is_blinking = true
	blink_total = duration
	blink_timer = 0.0
	blink_visible = true

func stop_blink() -> void:
	is_blinking = false
	blink_total = 0.0
	blink_timer = 0.0
	blink_visible = true

# Frame logic
func handle(delta: float) -> void:
	if damaged:
		damage_timer -= delta
		if damage_timer <= 0:
			damaged = false
	
	# Rotation
	if target_direction != Vector2.ZERO:
		var target_angle = target_direction.angle()
		if use_smooth_rotation:
			body.rotation = lerp_angle(body.rotation, target_angle, rotation_speed * delta)
		else:
			body.rotation = target_angle

	# Blink
	if is_blinking:
		blink_total -= delta
		blink_timer -= delta
		if blink_timer <= 0.0:
			blink_timer = blink_duration
			blink_visible = not blink_visible
		if blink_total <= 0.0:
			stop_blink()

	# Transition
	if transition > 0.0:
		previous_opacity = transition
		current_opacity = 1.0 - transition
		transition = max(0.0, transition - delta * transition_speed)
	else:
		current_opacity = 1.0
		previous_opacity = 0.0
		
	if previous_opacity > 0.0 and animations.has(previous_id):
		animations[previous_id].update(delta)

	if current_opacity > 0.0 and animations.has(current_id):
		animations[current_id].update(delta)

	queue_redraw()

# Drawing
func _draw() -> void:
	var blink_opacity = 1.0  if blink_visible else 0.0
	var combined_damaged := damaged or not blink_visible
	
	#draw_set_transform(Vector2.ZERO, body.rotation, Vector2.ONE)

	if previous_opacity > 0.0 and animations.has(previous_id):
		animations[previous_id].draw(self, previous_opacity * blink_opacity, combined_damaged)

	if current_opacity > 0.0 and animations.has(current_id):
		animations[current_id].draw(self, current_opacity * blink_opacity, combined_damaged)
	
	#draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
