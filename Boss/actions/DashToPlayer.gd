extends BossAction
class_name DashToPlayerAction

var dash_speed: float = 400.0
var dash_duration: float = 0.5
var stop_distance: float = 30.0

func execute():
	print('DashToPlayer')
	boss.movement.look_at_player(boss.player)
	
	var timer = 0.0
	while timer < dash_duration:
		var distance = boss.movement.get_distance_to_player(boss.player)
		if distance <= stop_distance:
			break
			
		boss.movement.move_to_player(boss.player, dash_speed)
		await boss.get_tree().process_frame
		timer += get_process_delta_time()
	
	boss.movement.stop_movement()
