extends PlayerAnimation
class_name LightSlashAnimation1

const FORWARD_DURATION := 0.04
const RECOIL_DURATION := 0.04
const RETURN_DURATION := 0.06
const TOTAL_DURATION := FORWARD_DURATION + RECOIL_DURATION + RETURN_DURATION

func _init(player_ref: Player) -> void:
	super(player_ref)
	duration = TOTAL_DURATION

func draw(target: CanvasItem, opacity: float, damaged: bool) -> void:
	var base_radius := 20.0
	var triangle_size := 14.0

	var fill_color := Color(1, 1, 1, opacity) if damaged else Color(0, 0, 0, opacity)
	var stroke_color := Color(0, 0, 0, opacity) if damaged else Color(1, 1, 1, opacity)

	var x_scale := 1.0
	var y_scale := 1.0

	if timer <= FORWARD_DURATION:
		var t := timer / FORWARD_DURATION
		x_scale = lerp(1.0, 1.2, t)
		y_scale = lerp(1.0, 0.75, t)
	elif timer <= FORWARD_DURATION + RECOIL_DURATION:
		var t := (timer - FORWARD_DURATION) / RECOIL_DURATION
		x_scale = lerp(1.2, 0.7, t)
		y_scale = lerp(0.75, 1.15, t)
	elif timer <= TOTAL_DURATION:
		var t := (timer - FORWARD_DURATION - RECOIL_DURATION) / RETURN_DURATION
		x_scale = lerp(0.7, 1.0, t)
		y_scale = lerp(1.15, 1.0, t)

	 #Body deformation
	_draw_ellipse(target, Vector2.ZERO, base_radius, x_scale, y_scale, fill_color)
	_draw_ellipse(target, Vector2.ZERO, base_radius, x_scale, y_scale, stroke_color, 2.0)

	# Right-facing triangle
	var triangle := PackedVector2Array([
		Vector2(triangle_size, 0),
		Vector2(-triangle_size * 0.6, triangle_size * 0.6),
		Vector2(-triangle_size * 0.6, -triangle_size * 0.6)
	])
	target.draw_colored_polygon(triangle, stroke_color)
