extends BossAction
class_name WaitAction

var wait_duration: float = 2.0

func execute():
	print('Wait')
	await boss.get_tree().create_timer(wait_duration).timeout
