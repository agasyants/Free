extends BossAction
class_name BackstepShotAction

var move_duration := 1.0
var shoot_time := 0.3
var shot := false

func update(delta: float):
	timer += delta

	var dir = boss.movement.get_direction_to_player()
	boss.movement.set_velocity(-dir * 250)

	if not shot and timer >= shoot_time:
		shot = true
		boss.shoot.shoot(boss.global_position, dir)

	if timer >= move_duration:
		boss.movement.stop()
		finished = true
