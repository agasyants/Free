extends BossPhase
class_name EasyPhase2

func get_initial_action() -> BossAction:
	return ManyRingsWavesAction.new()

func start():
	add_transition(ManyRingsWavesAction, func(_prev):
		var chance = randf()

		if chance < 0.3:
			return DashAttackAction.new()
		else:
			return HeavySnipeAction.new()
	)
	
	add_transition(HeavySnipeAction, func(_prev):
		var chance = randf()

		if chance < 0.3:
			return ManyRingsWavesAction.new()
		else:
			return BackstepShotAction.new()
	)

	add_transition(BackstepShotAction, func(_prev):
		var chance = randf()
		if chance < 0.3:
			return HeavySnipeAction.new()
		else:
			return DashAttackAction.new()
	)
	
	add_transition(DashAttackAction, func(_prev):
		var chance = randf()
		if chance < 0.6:
			return BackstepShotAction.new()
		else:
			return ManyRingsWavesAction.new()
	)

	super.start()
