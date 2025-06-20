extends BossAction
class_name ShootAtPlayerAction

var shots_count: int = 10
var delay_between_shots: float = 0.5

func execute():
	print('ShootAtPlayer')
	boss.movement.look_at_player(boss.player)
	
	for i in range(shots_count):
		boss.shooting.shoot_at_player(boss.player)
		if i < shots_count - 1:
			await boss.get_tree().create_timer(delay_between_shots).timeout
