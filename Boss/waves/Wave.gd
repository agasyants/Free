extends RefCounted
class_name Wave

var duration: float
var timer: float
var damage: int

func _init(_duration: float, _damage: int) -> void:
	duration = _duration
	damage = _damage
	timer = 0.0

func update(delta: float) -> void:
	timer += delta

func is_active() -> bool:
	return timer <= duration

func render(_canvas: CanvasItem) -> void:
	# Must be overridden
	pass

func is_inside(_point: Vector2, _radius: float = 0.0) -> bool:
	# Must be overridden
	return false
