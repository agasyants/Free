extends Control
class_name VirtualStick

@export var radius: float = 60.0
@export var activation_radius: float = 80.0

var origin := Vector2.ZERO
var direction := Vector2.ZERO
var is_pressed := false
var tracked_finger_index := -1

func _ready():
	visible = DisplayServer.is_touchscreen_available()
	item_rect_changed.connect(_update_base_center)

	await get_tree().process_frame
	_update_base_center()
	_reset_stick()

func _update_base_center():
	origin = $Base.position + $Base.size / 2

func _gui_input(event):
	if not visible:
		return
	origin = $Base.position + $Base.size / 2
	
	if event is InputEventScreenTouch:
		var touch_pos = event.position
		var distance_to_origin = touch_pos.distance_to(origin)
		
		if event.pressed and distance_to_origin <= activation_radius and tracked_finger_index == -1:
			tracked_finger_index = event.index
			is_pressed = true
			_update_direction(touch_pos)
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == tracked_finger_index:
			_reset_stick()
			get_viewport().set_input_as_handled()
	
	elif event is InputEventScreenDrag and is_pressed and event.index == tracked_finger_index:
		_update_direction(event.position)
		get_viewport().set_input_as_handled()
		
	queue_redraw()

func _update_direction(touch_pos: Vector2):
	direction = (touch_pos - origin).limit_length(radius)
	$Stick.position = origin - $Stick.size / 2 + direction  # Обновляем позицию стика сразу

func _reset_stick():
	is_pressed = false
	direction = Vector2.ZERO
	tracked_finger_index = -1
	$Stick.position = origin - $Stick.size / 2
	
func get_vector() -> Vector2:
	return direction / radius if radius > 0 else Vector2.ZERO
