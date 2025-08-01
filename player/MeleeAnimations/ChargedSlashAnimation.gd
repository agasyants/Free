extends PlayerAnimation
class_name ChargedSlashAnimation

var slash_duration: float = 1.5
var trail_points: Array[Vector2] = []
var max_trail_length: int = 12
var slash_intensity: float = 0.0
var shake_timer: float = 0.0

func reset():
	timer = 0.0
	slash_duration = 1.5
	trail_points.clear()
	slash_intensity = 0.0
	shake_timer = 0.0
	finished = false

func update(delta: float) -> void:
	timer += delta
	shake_timer += delta
	
	# Интенсивность удара - быстрый подъем, медленный спад
	if timer < 0.2:
		slash_intensity = timer / 0.2  # Быстрый подъем
	else:
		slash_intensity = 1.0 - ((timer - 0.2) / (slash_duration - 0.2))  # Медленный спад
	
	slash_intensity = clamp(slash_intensity, 0.0, 1.0)
	
	# Добавляем точки следа (имитация движения)
	var trail_offset = Vector2(sin(timer * 15.0) * 2.0, cos(timer * 12.0) * 1.5)
	trail_points.append(trail_offset)
	
	if trail_points.size() > max_trail_length:
		trail_points.pop_front()
	
	if not finished and timer >= slash_duration:
		finished = true
		emit_signal("animation_finished")

func draw(target: CanvasItem, opacity: float, damaged: bool) -> void:
	var base_radius: float = 25.0
	var fill_color: Color = Color(1, 1, 1, opacity) if damaged else Color(0, 0, 0, opacity)
	var stroke_color: Color = Color(0, 0, 0, opacity) if damaged else Color(1, 1, 1, opacity)
	
	# Основной круг с легким тряском
	var shake_offset = Vector2(
		sin(shake_timer * 30.0) * slash_intensity * 2.0,
		cos(shake_timer * 25.0) * slash_intensity * 1.5
	)
	
	target.draw_circle(shake_offset, base_radius, fill_color, true, -1, Settings.is_aa())
	target.draw_circle(shake_offset, base_radius, stroke_color, false, 2.0, Settings.is_aa())
	
	# Треугольник-стрелка с тряской
	var tri_size := 14.0
	var triangle := PackedVector2Array([
		Vector2(tri_size, 0) + shake_offset,
		Vector2(-tri_size * 0.6, tri_size * 0.6) + shake_offset,
		Vector2(-tri_size * 0.6, -tri_size * 0.6) + shake_offset
	])
	target.draw_polygon(triangle, [stroke_color])
	
	# След/шлейф от движения
	if trail_points.size() > 1:
		for i in range(trail_points.size() - 1):
			var alpha_factor = float(i) / float(trail_points.size() - 1)
			var trail_alpha = alpha_factor * slash_intensity * opacity * 0.7
			var trail_color = stroke_color
			trail_color.a = trail_alpha
			var width = 3.0 * alpha_factor * slash_intensity
			
			target.draw_line(
				trail_points[i], 
				trail_points[i + 1], 
				trail_color, 
				width, 
				Settings.is_aa()
			)
	
	# Линии скорости/удара справа
	var speed_line_count = 8
	var speed_length = 40.0 * slash_intensity
	var speed_alpha = slash_intensity * opacity
	
	for i in speed_line_count:
		var line_offset = Vector2(base_radius + 5.0 + i * 3.0, (float(i - speed_line_count)/2) * 4.0)
		var line_start = line_offset + shake_offset
		var line_end = line_start + Vector2(speed_length, 0)
		
		# Добавляем небольшой угол для динамики
		var angle_variation = sin(timer * 8.0 + i) * 0.1
		line_end.y += angle_variation * speed_length * 0.2
		
		var line_alpha = speed_alpha * (0.5 + 0.5 * sin(timer * 6.0 + i * 0.5))
		var speed_color = stroke_color
		speed_color.a = line_alpha
		
		target.draw_line(line_start, line_end, speed_color, 2.0, Settings.is_aa())
	
	# Ударные волны/кольца
	var wave_count = 3
	for i in wave_count:
		var wave_time = timer - i * 0.1
		if wave_time > 0.0:
			var wave_progress = clamp(wave_time / 0.5, 0.0, 1.0)
			var wave_radius = base_radius + wave_progress * 50.0
			var wave_alpha = (1.0 - wave_progress) * slash_intensity * opacity * 0.6
			var wave_color = stroke_color
			wave_color.a = wave_alpha
			
			target.draw_circle(shake_offset, wave_radius, wave_color, false, 2.0, Settings.is_aa())
	
	# Искры/частицы удара
	if slash_intensity > 0.3:
		var spark_count = 12
		var spark_distance = base_radius + 20.0
		
		for i in spark_count:
			var spark_angle = (TAU / spark_count) * i + timer * 4.0
			var spark_length = 8.0 + sin(timer * 10.0 + i) * 4.0
			var spark_alpha = slash_intensity * opacity * (0.4 + 0.6 * sin(timer * 8.0 + i * 0.7))
			
			var spark_start = Vector2(cos(spark_angle), sin(spark_angle)) * spark_distance + shake_offset
			var spark_end = spark_start + Vector2(cos(spark_angle), sin(spark_angle)) * spark_length
			
			var spark_color = stroke_color
			spark_color.a = spark_alpha
			
			target.draw_line(spark_start, spark_end, spark_color, 1.5, Settings.is_aa())
	
	# Мощная вспышка в начале удара
	if timer < 0.3:
		var flash_strength = (0.3 - timer) / 0.3
		var flash_radius = base_radius + flash_strength * 60.0
		var flash_alpha = flash_strength * slash_intensity * opacity * 0.4
		var flash_color = Color(1, 1, 1, flash_alpha)
		
		target.draw_circle(shake_offset, flash_radius, flash_color, true, -1, Settings.is_aa())
