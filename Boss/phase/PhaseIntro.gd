extends Phase
class_name RandomAttackPhase

var available_actions: Array[BossAction] = [CircularShootAction.new(), ChasePlayerAction.new()]
var attacks_performed: int = 0
var max_attacks: int = 100
var current_action: BossAction
var action_delay: float = 0.5
var delay_timer: float = 0.0
var is_waiting: bool = false

func start(boss_ref):
	super.start(boss_ref)
	attacks_performed = 0
	_start_random_action()

func update(delta):
	if not is_active:
		return
	
	if is_waiting:
		delay_timer -= delta
		if delay_timer <= 0:
			is_waiting = false
			_start_random_action()

func _start_random_action():
	if attacks_performed >= max_attacks:
		end()
		return
	
	var random_index = randi() % available_actions.size()
	current_action = available_actions[random_index]
	current_action.completed.connect(_on_action_completed)
	current_action.run(boss)

func _on_action_completed():
	current_action.completed.disconnect(_on_action_completed)
	attacks_performed += 1
	
	if attacks_performed < max_attacks:
		is_waiting = true
		delay_timer = action_delay
	else:
		end()
