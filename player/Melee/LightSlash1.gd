extends MeleeAttack
class_name LightSlash1

const FORWARD_SPEED := 1800.0
const RETURN_SPEED := 800.0
const ATTACK_DURATION := 0.08

func start() -> void:
	TOTAL_DURATION = 0.22
	DAMAGE = 8
	finished = false
	timer = 0.0
	damaged_bodies.clear()
	direction = owner.get_slash_direction().normalized()
	owner.body.animation_component.play("ATTACK_1")

func update(delta: float) -> void:
	timer += delta
	
	if timer <= ATTACK_DURATION:
		owner.body.velocity = direction * FORWARD_SPEED
	elif timer <= TOTAL_DURATION:
		owner.body.velocity = -direction * RETURN_SPEED
	else:
		finished = true
