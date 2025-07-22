extends PlayerAnimation
class_name ParryAnimation


func draw(target: CanvasItem, opacity: float, damaged: bool) -> void:
	var base_radius := 20.0
	var triangle_size := 14.0

	var fill_color := Color(1, 1, 1, opacity) if damaged else Color(0, 0, 0, opacity)
	var stroke_color := Color(0, 0, 0, opacity) if damaged else Color(1, 1, 1, opacity)

	# Основной круг
	target.draw_circle(Vector2.ZERO, base_radius, fill_color, true, -1, Settings.is_aa())
	target.draw_circle(Vector2.ZERO, base_radius, stroke_color, false, 2.0, Settings.is_aa())

	# Треугольник направления
	var tri_size := triangle_size
	var triangle := PackedVector2Array([
		Vector2(tri_size, 0),
		Vector2(-tri_size * 0.6, tri_size * 0.6),
		Vector2(-tri_size * 0.6, -tri_size * 0.6)
	])
	target.draw_polygon(triangle, [stroke_color])

	# Эффект парирования — пульсирующее внешнее кольцо
	var ring_base := base_radius + 8.0
	var ring_variation := 2.0 * sin(timer * 12.0)
	var ring_radius := ring_base + ring_variation

	target.draw_circle(Vector2.ZERO, ring_radius, stroke_color, false, 2.5, Settings.is_aa())
