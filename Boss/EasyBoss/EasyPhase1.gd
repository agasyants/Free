extends BossPhase
class_name EasyPhase1

func get_initial_action() -> BossAction:
	return CircleAndShootAction.new()

func start():
	add_transition(LaserSweepLeftAction, func(_prev):
		var chance = randf()

		if chance < 0.4:
			return CircleAndShootAction.new()
		else:
			return DashAttackAction.new()
	)
	
	add_transition(LaserSweepRightAction, func(_prev):
		var chance = randf()

		if chance < 0.4:
			return CircleAndShootAction.new()
		else:
			return BackstepShotAction.new()
	)
	
	add_transition(BackstepShotAction, func(_prev):
		var chance = randf()

		if chance < 0.2:
			return DualLaserSweepAction.new()
		elif chance < 0.6:
			return LaserSweepLeftAction.new()
		else:
			return LaserSweepRightAction.new()
	)

	add_transition(CircleAndShootAction, func(_prev):
		var chance = randf()
		if chance < 0.7:
			return DualLaserSweepAction.new()
		else:
			return BackstepShotAction.new()
	)
	
	add_transition(DualLaserSweepAction, func(_prev):
		var dist = boss.movement.get_distance_to_player()
		
		if dist < 800:
			return BackstepShotAction.new()
		else:
			return DashAttackAction.new()
	)
	
	add_transition(DashAttackAction, func(_prev):
		var chance = randf()

		if chance < 0.3:
			return DualLaserSweepAction.new()
		elif chance < 0.7:
			return LaserSweepLeftAction.new()
		else:
			return LaserSweepRightAction.new()
	)

	super.start()
