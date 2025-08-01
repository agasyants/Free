extends MeleeAttack
class_name LightSlash3

const FORWARD_SPEED := 2000.0
const RETURN_SPEED := 800.0
const PRE_SPEED := 1000.0
const ATTACK_DURATION := 0.1
const PRE_ATTACK_DURATION := 0.06

func start() -> void:
	TOTAL_DURATION = 0.3
	DAMAGE = 8
	finished = false
	timer = 0.0
	damaged_bodies.clear()
	direction = owner.get_slash_direction().normalized()
	owner.body.animation_component.play("ATTACK_3")

func update(delta: float) -> void:
	timer += delta
	if timer <= PRE_ATTACK_DURATION:
		owner.body.velocity = -direction * PRE_SPEED
	elif timer <= ATTACK_DURATION + PRE_ATTACK_DURATION:
		owner.body.velocity = direction * FORWARD_SPEED
	elif timer <= TOTAL_DURATION:
		owner.body.velocity = -direction * RETURN_SPEED
	else:
		finished = true
