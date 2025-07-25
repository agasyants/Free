extends BossPhase
class_name FinalPhase

var snipe_counter = 0

func get_initial_action() -> BossAction:
	return HeavySnipeAction.new()

func start():
	add_transition(HeavySnipeAction, func(_prev):
		if snipe_counter < 5:
			snipe_counter += 1
			return HeavySnipeAction.new()
		else:
			snipe_counter = 0
			return RingWaveAttackAction.new()
	)
	add_transition(RingWaveAttackAction, func(_prev):
		return HeavySnipeAction.new()
	)
	super.start()
