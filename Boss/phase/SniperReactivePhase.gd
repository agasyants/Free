extends BossPhase
class_name SniperReactivePhase

func get_initial_action() -> BossAction:
	return BackstepShotAction.new()

func start():
	add_transition(BackstepShotAction, func(_prev):
		var dist = boss.movement.get_distance_to_player()

		if dist > 500:
			return HeavySnipeAction.new()
		else:
			return DashAttackAction.new()
	)

	add_transition(HeavySnipeAction, func(_prev):
		return CircleAndShootAction.new()
	)

	add_transition(CircleAndShootAction, func(_prev):
		var chance = randf()
		if chance < 0.4:
			return HeavySnipeAction.new()
		else:
			return DashAttackAction.new()
	)

	add_transition(DashAttackAction, func(_prev):
		var chance = randf()
		if chance < 0.5:
			return LaserSweepLeftAction.new()
		else:
			return LaserSweepRightAction.new()
	)
	add_transition(LaserSweepLeftAction, func(_prev):
		var chance = randf()
		if chance < 0.4:
			return LaserSweepLeftAction.new()
		else:
			return BackstepShotAction.new()
	)
	add_transition(LaserSweepRightAction, func(_prev):
		var chance = randf()
		if chance < 0.5:
			return HeavySnipeAction.new()
		else:
			return LaserSweepLeftAction.new()
	)

	super.start()
