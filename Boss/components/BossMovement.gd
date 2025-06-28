extends Node
class_name BossMovementComponent

var boss: CharacterBody2D

var velocity: Vector2 = Vector2.ZERO

func _ready():
	boss = get_parent().get_parent() as CharacterBody2D

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
func update(_delta: float):
	boss.velocity = velocity
	boss.move_and_slide()

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
