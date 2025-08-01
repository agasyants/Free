extends RefCounted
class_name MeleeAttack

var finished := false
var owner: MeleeAttackComponent
var damaged_bodies := {}
var DAMAGE
var direction := Vector2.ZERO
var timer := 0.0
var TOTAL_DURATION

func _init(_owner: MeleeAttackComponent) -> void:
	owner = _owner

func start() -> void:
	pass

func update(_delta: float) -> void:
	pass

func cancel() -> void:
	finished = true
	owner._disable_damage()
	owner.body.velocity = Vector2.ZERO

func on_body_entered(body: Node2D) -> void:
	if finished:
		return
	if body in damaged_bodies:
		return
	if not body.has_method("take_damage"):
		return

	damaged_bodies[body] = true
	body.take_damage(DAMAGE)
	
	var camera: Camera = owner.get_viewport().get_camera_2d()
	camera.add_shake(6, 0.25, 0.01, Vector2.ZERO, true, true, 2.0)
	
	Engine.time_scale = 0.0
	await owner.get_tree().create_timer(0.08, false, false, true).timeout
	Engine.time_scale = 1.0

func get_time_left() -> float:
	return TOTAL_DURATION - timer
