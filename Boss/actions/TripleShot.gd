extends BossAction
class_name TripleSpreadShotAction

func update(delta: float):
	print('TripleSpreadShotAction')
	if timer == 0.0:
		var dir = boss.shoot.get_direction_to_player()
		boss.shoot.shoot(boss.global_position, dir, 600)
		boss.shoot.shoot(boss.global_position, boss.shoot.get_offset_direction(dir, -15), 600)
		boss.shoot.shoot(boss.global_position, boss.shoot.get_offset_direction(dir, 15), 600)
		finished = true

	timer += delta
