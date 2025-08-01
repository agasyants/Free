extends MeleeAttack
class_name ChargedSlash

const FORWARD_SPEED := 2000.0
const RETURN_SPEED := 500.0
var ATTACK_DURATION

func starting(dur: float) -> void:
	dur = clamp(dur, 0.0, 2.5) / 5
	TOTAL_DURATION = dur
	ATTACK_DURATION = dur
	DAMAGE = 8
	finished = false
	timer = 0.0
	damaged_bodies.clear()
	direction = owner.get_slash_direction().normalized()
	owner.body.animation_component.play("CHARGED_ATTACK")

func update(delta: float) -> void:
	timer += delta
	if timer <= ATTACK_DURATION:
		owner.body.velocity = direction * FORWARD_SPEED
	elif timer <= TOTAL_DURATION:
		owner.body.velocity = -direction * RETURN_SPEED
	else:
		finished = true

func on_body_entered(body: Node2D) -> void:
	if finished:
		return
	if body in damaged_bodies:
		return
	if not body.has_method("take_damage"):
		return
	damaged_bodies[body] = true
	body.take_damage(DAMAGE)
