extends Arena

func _draw():
	# Base dark circle
	draw_circle(Vector2.ZERO, radius, base_color)
	
	# Inner concentric circles
	var rings = 8
	for i in range(1, rings + 1):
		var ring_radius = radius * i / rings * 0.8
		var ring_color = grid_color
		ring_color.a = 0.3 - (i * 0.02)
		draw_arc(Vector2.ZERO, ring_radius, 0, TAU, 64, ring_color, 1.0)
	
	# Main grid lines (8 segments)
	var main_segments = 8
	for i in range(main_segments):
		var angle = TAU * i / main_segments
		var direction = Vector2.RIGHT.rotated(angle)
		var line_color = grid_color
		line_color.a = 0.4
		draw_line(Vector2.ZERO, direction * radius, line_color, 1.5)
	
	# Secondary grid lines (16 segments, thinner)
	var secondary_segments = 16
	for i in range(secondary_segments):
		var angle = TAU * i / secondary_segments + (TAU / 32)
		var direction = Vector2.RIGHT.rotated(angle)
		var line_color = grid_color
		line_color.a = 0.15
		draw_line(Vector2.ZERO, direction * radius * 0.7, line_color, 0.8)
	
	# Accent cross lines (red)
	var cross_angles = [0, PI/2, PI, 3*PI/2]
	for angle in cross_angles:
		var direction = Vector2.RIGHT.rotated(angle)
		var accent_line_color = accent_color
		accent_line_color.a = 0.6
		draw_line(Vector2.ZERO, direction * radius, accent_line_color, 2.0)
	
	# Central dot
	draw_circle(Vector2.ZERO, 4.0, Color(0.6, 0.6, 0.6, 0.8))
	
	# Outer border
	var outer_border = border_color
	outer_border.a = 0.5
	draw_arc(Vector2.ZERO, radius, 0, TAU, 128, outer_border, 3.0)
	
	# Inner border for depth
	var inner_border = Color(0.2, 0.2, 0.2)
	inner_border.a = 0.8
	draw_arc(Vector2.ZERO, radius - 10, 0, TAU, 128, inner_border, 1.5)
