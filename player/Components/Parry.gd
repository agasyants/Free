extends Node
class_name ParryComponent
## Компонент парирования игрока
## Отвечает за включение парирования и обработку парируемых объектов

signal parry_started
signal parry_ended

@export var active_time: float = 0.3
@export var cooldown: float = 0.7

var active_timer: float = 0.0
var cooldown_timer: float = 0.0

@onready var body: CharacterBody2D = get_parent().get_parent()

func handle(delta: float) -> void:
	if Input.is_action_pressed("parry") and cooldown_timer <= 0.0 and not is_parrying():
		_start_parry()

	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	if is_parrying():
		active_timer -= delta
		if active_timer <= 0.0:
			_end_parry()

func _start_parry() -> void:
	body.set_state(types.PlayerState.PARRY)
	active_timer = active_time
	cooldown_timer = cooldown
	emit_signal("parry_started")

func _end_parry() -> void:
	body.set_state(types.PlayerState.IDLE)
	emit_signal("parry_ended")
	
func is_parrying() -> bool:
	return body.state == types.PlayerState.PARRY
