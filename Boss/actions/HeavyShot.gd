extends BossAction
class_name HeavySnipeAction

var aim_time := 0.7
var fired := false

func update(delta: float):
	print('HeavySnipeAction')
	timer += delta

	boss.movement.look_at_player()

	if not fired and timer >= aim_time:
		fired = true
		var dir = boss.shoot.get_direction_to_player()
		boss.shoot.shoot(boss.global_position, dir, 1000, "heavy")
		finished = true
