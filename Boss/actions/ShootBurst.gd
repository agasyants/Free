extends BossAction
class_name ShootBurstAction

var burst_count: int = 3
var burst_delay: float = 0.2
var shot_delay: float = 0.1

func execute():
	print('ShootBurst')
	await boss.shooting.shoot_burst(boss.player.global_position, burst_count, burst_delay, shot_delay)
