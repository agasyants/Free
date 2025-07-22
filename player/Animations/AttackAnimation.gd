extends PlayerAnimation
class_name AttackAnimation

var base_radius := 20.0
var stretch_distance := 60.0
var stretch_angle := deg_to_rad(45.0)  # ширина расщепления формы
var segment_count := 32
#var duration := 0.2

#func _init():
	#self.duration = duration

func draw(target: CanvasItem, opacity: float, damaged: bool) -> void:
	var fill_color := Color(0, 0, 0, opacity) if not damaged else Color(1, 1, 1, opacity)
	var stroke_color := Color(1, 1, 1, opacity) if not damaged else Color(0, 0, 0, opacity)

	# Параметры времени
	var progress = clamp(timer / duration, 0.0, 1.0)
	var ease = sin(progress * PI)

	# Динамическая форма: жидкий круг с острым вытягиванием вперёд
	var points := PackedVector2Array()

	for i in segment_count:
		var angle := TAU * i / segment_count
		var dir := Vector2(cos(angle), sin(angle))

		var within_slash = abs(wrapf(angle, -PI, PI)) < stretch_angle * 0.5

		var dynamic_radius := base_radius
		if within_slash:
			dynamic_radius += stretch_distance * ease * (1.0 - abs(angle) / stretch_angle)
		
		points.append(dir * dynamic_radius)

	# Основное тело
	target.draw_polygon(points, [fill_color])

	# Обводка
	target.draw_polyline(points, stroke_color, 2.0)
	target.draw_line(points[-1], points[0], stroke_color, 2.0)
