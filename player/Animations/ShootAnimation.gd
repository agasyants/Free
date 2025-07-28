extends PlayerAnimation
class_name ShootAnimation

func draw(target: CanvasItem, opacity: float, damaged: bool) -> void:
	var radius := 20.0
	var triangle_size := 14.0

	var fill_color := Color(1, 1, 1, opacity) if damaged else Color(0, 0, 0, opacity)
	var stroke_color := Color(0, 0, 0, opacity) if damaged else Color(1, 1, 1, opacity)
	
	if Settings.get_bool('laser'):
		var dir = player.animation_component.target_direction.rotated(-player.rotation)
		target.draw_line(Vector2.ZERO, dir * 1000, stroke_color, 1, Settings.is_aa())

	# тело
	target.draw_circle(Vector2.ZERO, radius, fill_color, true, -1, Settings.is_aa())
	target.draw_circle(Vector2.ZERO, radius, stroke_color, false, 2.0, Settings.is_aa())

	# треугольник направления (направо)
	var triangle := PackedVector2Array([
		Vector2(triangle_size, 0),
		Vector2(-triangle_size * 0.6, triangle_size * 0.6),
		Vector2(-triangle_size * 0.6, -triangle_size * 0.6)
	])
	target.draw_colored_polygon(triangle, stroke_color)
