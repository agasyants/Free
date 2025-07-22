extends Node2D
class_name BossLaserComponent

var current_lasers: Array = []
var boss: Boss
var player: Node2D

func _ready():
	boss = get_parent().get_parent() as Boss
	player = get_tree().get_first_node_in_group("player")

func fire_lasers(lasers_array: Array):
	current_lasers.clear()

	var viewport_rect = get_viewport().get_visible_rect()
	var max_distance = max(viewport_rect.size.x, viewport_rect.size.y) * 2.0
	var space_state = get_world_2d().direct_space_state

	for laser in lasers_array:
		var from = laser.from
		var dir = laser.direction.normalized()
		var damage = laser.damage
		var color: Color = laser.get("color", Color.RED)
		var width: float = laser.get("width", 3.0)

		var to = from + dir * max_distance

		# Создаём параметр raycast-запроса
		var query = PhysicsRayQueryParameters2D.create(from, to)
		query.exclude = [boss]

		var result = space_state.intersect_ray(query)

		if result:
			to = result.position
			if result.collider == player:
				player.take_damage(damage)
		
		current_lasers.append({
			"from": from,
			"to": to,
			"color": color,
			"width": width
		})
	queue_redraw()

func _draw() -> void:
	var time := Time.get_ticks_msec() / 1000.0

	for laser in current_lasers:
		var from = to_local(laser.from)
		var to = to_local(laser.to)
		var dir = to - from
		var normal = dir.normalized()
		var perp = Vector2(-normal.y, normal.x)

		# Pulse animation
		var pulse = sin(time * 15.0) * 0.1 + 1.0

		# Laser dimensions
		var main_width = laser.width * pulse
		var white_core_width = main_width * 0.4

		# Colors
		var color = laser.color
		draw_line(from, to, color, main_width, Settings.is_aa())
		draw_line(from, to, Color(1, 1, 1, 1), white_core_width, Settings.is_aa())

		
		if Settings.is_trails():
			# Energy particles
			var particle_count = 8
			for i in range(particle_count):
				var phase = float(i) / particle_count + time
				var particle_t = fmod(phase, 1.0)
				var pos = from.lerp(to, particle_t)
				var particle_offset = sin(time * 10.0 + i) * 5.0
				var particle_pos = pos + perp * particle_offset
				var size = 2.0 + sin(time * 20.0 + i) * 1.5
				draw_circle(particle_pos, size, Color(1, 1, 1, 1), true, -1, Settings.is_aa())


# ======== УТИЛИТЫ ДЛЯ ACTION'ОВ ========

# Вектор направления на игрока
func get_direction_to_player() -> Vector2:
	return (player.global_position - boss.global_position).normalized()

# Направление с отклонением в градусах
func get_offset_direction_from_player(degrees: float) -> Vector2:
	return get_direction_to_player().rotated(deg_to_rad(degrees))

# Угол на игрока (в радианах)
func get_angle_to_player() -> float:
	return (player.global_position - boss.global_position).angle()

# Угол на игрока + смещение (в радианах)
func get_offset_angle_from_player(degrees: float) -> float:
	return get_angle_to_player() + deg_to_rad(degrees)

# Вектор направления по углу (в градусах)
func angle_to_vector(degrees: float) -> Vector2:
	return Vector2.RIGHT.rotated(deg_to_rad(degrees))

# Градусы из вектора
func vector_to_angle(vec: Vector2) -> float:
	return rad_to_deg(vec.angle())

# Вращает from_dir с заданной скоростью (в град/сек) в указанную сторону
# clockwise: true — по часовой, false — против
func rotate_direction_with_speed(from_dir: Vector2, delta: float, degrees_per_sec: float, clockwise: bool) -> Vector2:
	var angle = from_dir.angle()
	var step = deg_to_rad(degrees_per_sec) * delta
	if clockwise:
		step *= -1
	var new_angle = angle + step
	return Vector2.RIGHT.rotated(new_angle)
