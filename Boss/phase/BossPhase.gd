extends RefCounted
class_name BossPhase

var boss: Node
var current_action: BossAction = null
var transitions := {}

func start():
	current_action = get_initial_action()
	if current_action:
		current_action.boss = boss

func update(delta: float):
	if current_action:
		current_action.update(delta)

		if current_action.finished:
			var next = _get_next_action_for(current_action)
			if next:
				current_action = next
				current_action.boss = boss
			else:
				current_action = null  # фаза завершена

func get_initial_action() -> BossAction:
	return null

func add_transition(action_type: Script, logic_fn: Callable):
	transitions[action_type] = logic_fn

func _get_next_action_for(prev: BossAction) -> BossAction:
	var action_type = prev.get_script()
	if transitions.has(action_type):
		var fn = transitions[action_type]
		return fn.call(prev)
	return null
