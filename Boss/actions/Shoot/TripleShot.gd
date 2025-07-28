extends BossAction
class_name TripleSpreadShotAction

func update(delta: float):
	if timer == 0.0:
		shooting()
		
	if timer > 0.1:
		shooting()
		finished = true
	
	timer += delta

func shooting():
	var dir = boss.shoot.get_direction_to_player()
	boss.shoot.shoot(boss.global_position, dir)
	boss.shoot.shoot(boss.global_position, boss.shoot.get_offset_direction(dir, -16))
	boss.shoot.shoot(boss.global_position, boss.shoot.get_offset_direction(dir, -8))
	boss.shoot.shoot(boss.global_position, boss.shoot.get_offset_direction(dir, 8))
	boss.shoot.shoot(boss.global_position, boss.shoot.get_offset_direction(dir, 16))
	boss.shoot.shoot(boss.global_position, boss.shoot.get_offset_direction(dir, -12))
	boss.shoot.shoot(boss.global_position, boss.shoot.get_offset_direction(dir, -4))
	boss.shoot.shoot(boss.global_position, boss.shoot.get_offset_direction(dir, 4))
	boss.shoot.shoot(boss.global_position, boss.shoot.get_offset_direction(dir, 12))
