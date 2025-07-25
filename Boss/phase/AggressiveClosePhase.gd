extends BossPhase
class_name AggressiveClosePhase

func get_initial_action() -> BossAction:
	return DashAttackAction.new()

func start():
	add_transition(DashAttackAction, func(_prev):
		var dist = boss.movement.get_distance_to_player()

		if dist > 300:
			return DashAttackAction.new()
		else:
			return TripleSpreadShotAction.new()
	)

	add_transition(TripleSpreadShotAction, func(_prev):
		var chance = randf()

		if chance < 0.2:
			return CircleAndShootAction.new()
		else:
			return DualLaserSweepAction.new()
	)

	add_transition(CircleAndShootAction, func(_prev):
		var chance = randf()

		if chance < 0.7:
			return ManyRingsWavesAction.new()
		else:
			return DashAttackAction.new()
	)

	add_transition(ManyRingsWavesAction, func(_prev):
		return DashAttackAction.new()
	)
	
	add_transition(DualLaserSweepAction, func(_prev):
		return TripleSpreadShotAction.new()
	)

	super.start()
