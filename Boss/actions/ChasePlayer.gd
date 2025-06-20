extends BossAction
class_name ChasePlayerAction

@export var chase_duration: float = 3.0
@export var chase_speed: float = 100.0

var _interrupted := false

func execute():
	if not _validate_requirements():
		return
	
	print('ChasePlayer')
	_interrupted = false
	
	var timer = get_tree().create_timer(chase_duration)
	await timer.timeout
	
	# Или Вариант 2: Через процесс (если нужно более точное управление)
	# var timer = 0.0
	# while timer < chase_duration and not _interrupted:
	#     if not _validate_requirements():
	#         return
	#     
	#     boss.movement.move_to_player(boss.player, chase_speed)
	#     boss.movement.look_at_player(boss.player)
	#     await get_tree().process_frame
	#     timer += get_tree().get_frame_delta_time()
	
	if not _interrupted:
		boss.movement.stop_movement()

func interrupt():
	_interrupted = true
	if is_instance_valid(boss) and boss.has_method("movement"):
		boss.movement.stop_movement()

func _validate_requirements() -> bool:
	if not is_instance_valid(boss):
		return false
	if not boss.has_node("movement"):
		return false
	if not is_instance_valid(boss.player):
		return false
	return true
