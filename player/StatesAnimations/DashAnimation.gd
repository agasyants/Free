extends PlayerAnimation
class_name DashAnimation

const ELLIPSE_SEGMENTS := 8
var start_pos: Vector2

func _init(player_ref: Player) -> void:
	super(player_ref)
	start_pos = player.global_position

func draw(target: CanvasItem, opacity: float, damaged: bool) -> void:
	var base_radius := 20.0
	var fill_color := Color(1, 1, 1, opacity) if damaged else Color(0, 0, 0, opacity)
	var stroke_color := Color(0, 0, 0, opacity) if damaged else Color(1, 1, 1, opacity)
	var x_scale := 1.2  # Более вытянутый для эффекта скорости
	var y_scale := 0.9
	# Directional offset
	var offset := (start_pos - player.global_position).rotated(-player.rotation)
	var trail_length := offset.length() / 30.0
	var trail_dir := offset.rotated(PI / 2).normalized()
	
	# Trail drawing
	for i in range(int(trail_length)):
		var w := (i + 1) / trail_length
		var pos := offset * w + trail_dir * ((randf() - 0.5) * 10.0)
		var trail_opacity := 0.01 + (1.0 - w) * 0.9
		_draw_ellipse(target, pos, base_radius, x_scale, y_scale, stroke_color, trail_opacity)
	
	# Рисуем основной объект (поверх трейла)
	_draw_ellipse(target, Vector2.ZERO, base_radius, x_scale, y_scale, fill_color, -1.0)
	_draw_ellipse(target, Vector2.ZERO, base_radius, x_scale, y_scale, stroke_color, 1.0)
	
	# Основной треугольник направления
	var tri_size := 16.0
	var k := 0.2
	var triangle := PackedVector2Array([
		Vector2(tri_size, 0),
		Vector2(-tri_size * k, tri_size * k),
		Vector2(-tri_size * k, -tri_size * k)
	])
	target.draw_colored_polygon(triangle, stroke_color)

func reset() -> void:
	super.reset()
	start_pos = player.global_position
