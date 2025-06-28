extends BossPhase
class_name RandomPhase

var pool := [
	DashAttackAction,
	TripleSpreadShotAction,
	CircleAndShootAction,
	BackstepShotAction,
	HeavySnipeAction
]

func get_initial_action() -> BossAction:
	return _random_action(null)

func start():
	for action_type in pool:
		add_transition(action_type, func(prev):
			return _random_action(prev)
	)

	super.start()

func _random_action(prev: BossAction) -> BossAction:
	var available := []

	for action_type in pool:
		if prev == null or not prev == action_type:
			available.append(action_type)

	if available.is_empty():
		return pool.pick_random().new()

	return available.pick_random().new()
