extends BossAction
class_name CircularShootAction

var shots_count: int = 8
var delay_between_shots: float = 0.1

func execute():
	print('CircularShoot')
	var angle_step = 2 * PI / shots_count
	
	for i in range(shots_count):
		var angle = i * angle_step
		var target_pos = boss.global_position + Vector2(cos(angle), sin(angle)) * 500
		boss.shooting.shoot_at_position(target_pos)
		
		if i < shots_count - 1:
			await boss.get_tree().create_timer(delay_between_shots).timeout
