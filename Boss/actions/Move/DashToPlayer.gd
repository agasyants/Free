extends BossAction
class_name DashAttackAction

var dash_speed := 800.0
var dash_duration := 0.3

func update(delta: float):
	timer += delta

	if timer == delta:
		var dir = boss.movement.get_direction_to_player()
		boss.movement.set_velocity(dir * dash_speed)

	if timer >= dash_duration:
		boss.movement.stop()
		finished = true
