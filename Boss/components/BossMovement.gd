extends Node
class_name BossMovementComponent

@onready var boss: Boss  = get_parent().get_parent()

var velocity: Vector2 = Vector2.ZERO

# Направление движения
func set_velocity(vel: Vector2):
	velocity = vel

# Упрощённое движение в сторону
func move_towards(pos: Vector2, speed: float):
	var dir = (pos - boss.global_position).normalized()
	velocity = dir * speed

# Остановка
func stop():
	velocity = Vector2.ZERO

# Обновление
func update(delta: float):
	boss.velocity = velocity
	_process_recoil(delta)
	boss.move_and_slide()
	
var recoil_velocity: Vector2 = Vector2.ZERO

func add_recoil(direction: Vector2, power: float) -> void:
	"""Добавляет отталкивающую силу в заданном направлении"""
	recoil_velocity = direction.normalized() * power

func _process_recoil(delta: float) -> void:
	if recoil_velocity != Vector2.ZERO:
		var damping: float = 10.0  # Увеличиваем для более резкого затухания
		var min_recoil: float = 1.0
		# Формула резкого затухания
		recoil_velocity = recoil_velocity.lerp(
			Vector2.ZERO,
			1.0 - exp(-damping * delta)  # Более крутой спад
		)
		boss.velocity += recoil_velocity
		if recoil_velocity.length() < min_recoil:
			recoil_velocity = Vector2.ZERO

# Текущая позиция босса
func get_position() -> Vector2:
	return boss.global_position

# Позиция игрока
func get_player_position() -> Vector2:
	return boss.player.global_position

# Расстояние до игрока
func get_distance_to_player() -> float:
	return boss.global_position.distance_to(get_player_position())

# Расстояние до любой точки
func get_distance_to(pos: Vector2) -> float:
	return boss.global_position.distance_to(pos)

# Направление на игрока
func get_direction_to_player() -> Vector2:
	return (get_player_position() - boss.global_position).normalized()

# Направление к любой точке
func get_direction_to(pos: Vector2) -> Vector2:
	return (pos - boss.global_position).normalized()

# Повернуться к игроку
func look_at_player():
	boss.look_at(get_player_position())

# Повернуться к точке
func look_at_point(pos: Vector2):
	boss.look_at(pos)
