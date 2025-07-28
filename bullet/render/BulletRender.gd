extends RefCounted
class_name BulletRenderer

func update(bullet: BulletData, delta: float) -> void:
	bullet.time += delta

	if Engine.get_frames_drawn() % 2 == 0:
		bullet.trail.insert(0, bullet.position)
		if bullet.trail.size() > bullet.MAX_TRAIL_LENGTH:
			bullet.trail.pop_back()

func draw_canvas(target: CanvasItem, bullet: BulletData) -> void:
	var t = bullet.time
	var base_radius = bullet.radius
	var pos = bullet.position
	
	if Settings.is_trails():
		# Трейл
		for i in range(bullet.trail.size()):
			var local_pos = target.to_local(bullet.trail[i])
			var alpha = 1.0 - float(i) / bullet.MAX_TRAIL_LENGTH
			var size = base_radius * 0.4 * alpha
			target.draw_circle(local_pos, size, Color(1, 1, 1, alpha * 0.6))
		
	var CORE_COLOR := Color.WHITE * 4.0
	var FLASH_COLOR := Color.WHITE * 8.0
	#var OUTLINE_RADIUS := 14.0

	# Контур с резкой пульсацией
	var pulse = sin(t * 30.0)
	target.draw_arc(pos, base_radius + pulse, 0, TAU, 16, 
			Color.WHITE, 1.5 + pulse * 0.2, true)
	
	# Ядро с хаотичной пульсацией
	var core_pulse = abs(sin(t * 40.0 + 1.0)) * 2 + abs(cos(t * 35.0)) * 2
	target.draw_circle(pos, base_radius/3 + core_pulse, CORE_COLOR)
	
	# Резкая вспышка при появлении
	if t < 0.15:  
		var flash_intensity = pow((0.15 - t) / 0.15, 0.5)
		target.draw_circle(pos, 30 * flash_intensity, 
				  FLASH_COLOR * flash_intensity)


func apply_to_multimesh(_index: int, _multimesh: MultiMesh) -> void:
	# Пока ничего, но задел на будущее
	pass
