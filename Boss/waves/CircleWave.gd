# wave/CircleWave.gd
extends Wave
class_name CircleWave

var center: Vector2
var max_radius: float
var color: Color = Color(1, 0, 0, 0.5)

func _init(
	_center: Vector2,
	_max_radius: float,
	_color: Color,
	_duration: float,
	_damage: int
) -> void:
	super._init(_duration, _damage)
	center = _center
	max_radius = _max_radius
	color = _color

func _get_radius(time: float) -> float:
	var t = clamp(time / duration, 0.0, 1.0)
	return max_radius * t

func render(canvas: CanvasItem) -> void:
	var r = _get_radius(timer)
	canvas.draw_circle(center, r, color, true, -1, Settings.is_aa())

func is_inside(point: Vector2, radius: float = 0.0) -> bool:
	var r = _get_radius(timer)
	return center.distance_to(point) <= r + radius
