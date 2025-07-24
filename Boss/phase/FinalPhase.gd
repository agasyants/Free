extends BossPhase
class_name FinalPhase

var snipe_counter = 0

func get_initial_action() -> BossAction:
	return HeavySnipeAction.new()

func start():
	add_transition(HeavySnipeAction, func(_prev):
		if snipe_counter < 5:
			return HeavySnipeAction.new()
		else:
			return RingWaveAttackAction.new()
	)
	add_transition(RingWaveAttackAction, func(_prev):
		return RingWaveAttackAction.new()
	)
	super.start()
