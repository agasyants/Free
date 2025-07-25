extends BossPhase
class_name WaitForPlayerPhase

var angle := 0.0
var radius := 200.0
var speed := 5.0

func start():
	boss.health.set_invulnerable(true)
	print("Boss is waiting for player respawn...")

func update(delta: float):
	if boss.player == null:
		return
	# Update the angle over time
	angle += speed * delta
	# Target position on circle around player
	var target_position = boss.player.global_position + Vector2(cos(angle), sin(angle)) * radius
	# Direction to move
	var direction = (target_position - boss.global_position).normalized()
	var velocity = direction * 800  # use defined speed from component if available
	# Move the boss using CharacterBody2D logic
	boss.velocity = velocity
	boss.move_and_slide()
