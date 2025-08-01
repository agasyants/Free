extends PlayerAnimation
class_name ChargingAttackAnimation

var charge_time: float = 2.5
var charged: bool = false
var charged_flash_timer: float = 0.0
var pulse_timer: float = 0.0

func reset():
	timer = 0.0
	charged_flash_timer = 0.0
	pulse_timer = 0.0
	charge_time = 2.5
	charged = false

func update(delta: float) -> void:
	timer += delta
	pulse_timer += delta
	
	if not charged and timer >= charge_time:
		charged = true
		charged_flash_timer = 0.3
	
	if charged_flash_timer > 0.0:
		charged_flash_timer -= delta

func draw(target: CanvasItem, opacity: float, damaged: bool) -> void:
	var base_radius: float = 20.0
	var fill_color: Color = Color(1, 1, 1, opacity) if damaged else Color(0, 0, 0, opacity)
	var stroke_color: Color = Color(0, 0, 0, opacity) if damaged else Color(1, 1, 1, opacity)
	
	# Основной круг
	var charge_ratio: float = clamp(timer / charge_time, 0.0, 1.0)
	
	target.draw_circle(Vector2.ZERO, base_radius, fill_color, true, -1, Settings.is_aa())
	target.draw_circle(Vector2.ZERO, base_radius, stroke_color, false, 2.5, Settings.is_aa())
	
	# Треугольник-стрелка (как в ChargingDashAnimation)
	var tri_size := 14.0
	var triangle := PackedVector2Array([
		Vector2(tri_size, 0),
		Vector2(-tri_size * 0.6, tri_size * 0.6),
		Vector2(-tri_size * 0.6, -tri_size * 0.6)
	])
	target.draw_polygon(triangle, [stroke_color])
	
	# Энергетические кольца зарядки
	var ring_alpha: float = charge_ratio * opacity
	var ring_color := stroke_color
	ring_color.a = ring_alpha
	
	var ring_count := 4
	for i in ring_count:
		var radius := base_radius + 8.0 + i * 6.0
		var rotation_speed := (0.8 + i * 0.3) * (-1 if i % 2 == 0 else 1)
		var angle_offset := timer * rotation_speed * TAU
		
		# Размер сегментов кольца увеличивается с зарядкой
		var segment_span := 0.3 + charge_ratio * 0.8
		var segments := 6
		
		for j in segments:
			var segment_angle := (TAU / segments) * j + angle_offset
			var start_angle := segment_angle
			var end_angle := segment_angle + segment_span
			
			var segment_alpha := ring_alpha * (0.7 + 0.3 * sin(pulse_timer * 4.0 + i + j))
			var segment_color := Color(ring_color.r, ring_color.g, ring_color.b, segment_alpha)
			
			target.draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 16, segment_color, 2.0, Settings.is_aa())
	
	# Пульсирующие точки энергии при зарядке
	if charge_ratio > 0.3:
		var point_count := 8
		var point_radius := base_radius + 35.0
		var pulse_strength := sin(pulse_timer * 6.0) * 0.5 + 0.5
		
		for i in point_count:
			var angle := (TAU / point_count) * i + timer * 2.0
			var point_pos := Vector2(cos(angle), sin(angle)) * point_radius
			var point_size := 2.0 + pulse_strength * 3.0 * charge_ratio
			var point_color := stroke_color
			point_color.a = charge_ratio * opacity * pulse_strength
			
			target.draw_circle(point_pos, point_size, point_color, true, -1, Settings.is_aa())
	
	# Мощная вспышка при полной зарядке
	if charged_flash_timer > 0.0:
		var flash_strength := charged_flash_timer / 0.3
		var flash_color := Color(1, 1, 1, flash_strength * opacity)
		var flash_radius := base_radius + 40.0 * (1.0 - flash_strength)
		
		# Основная вспышка
		target.draw_circle(Vector2.ZERO, flash_radius, flash_color, true, -1, Settings.is_aa())
		
		# Дополнительные кольца вспышки
		for i in 3:
			var ring_radius := flash_radius + i * 10.0
			var ring_flash_color := stroke_color
			ring_flash_color.a = flash_strength * 0.3 * opacity
			target.draw_circle(Vector2.ZERO, ring_radius, ring_flash_color, false, 2.0, Settings.is_aa())
