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
	body.take_damage(DAMAGE, 2, 'melee', direction)

func get_time_left() -> float:
	return TOTAL_DURATION - timer
