extends Node
class_name BossShootComponent

@onready var bullet_manager: BulletManager = get_node("/root/Node2D/BulletManager")

var boss: CharacterBody2D

func _ready():
	boss = get_parent().get_parent() as Node2D

# Запустить пулю
func shoot(origin: Vector2, direction: Vector2, bullet_type: String = "default"):
	match bullet_type:
		"default":
			bullet_manager.spawn_bullet({
				"position": origin,
				"velocity": direction,
				"speed": 500.0,
				"damage": 5,
				"health": 2,
				"radius": 14.0,
				"lifetime": 8.0,
				"is_player": false,
				"logic_id": "default",
				"renderer_id": "red"
			})
		"fast":
			bullet_manager.spawn_bullet({
				"position": origin,
				"velocity": direction,
				"speed": 1000.0,
				"damage": 1,
				"health": 1,
				"radius": 6.0,
				"lifetime": 3.0,
				"is_player": false,
				"logic_id": "homing",
				"renderer_id": "red"
			})
		"heavy":
			bullet_manager.spawn_bullet({
				"position": origin,
				"velocity": direction,
				"speed": 800.0,
				"damage": 20,
				"health": 6,
				"radius": 20.0,
				"lifetime": 30.0,
				"is_player": false,
				"logic_id": "homing",
				"renderer_id": "homing"
			})
		_:
			return null
		

# Направление до игрока
func get_direction_to_player() -> Vector2:
	return (boss.player.global_position - boss.global_position).normalized()

# Расстояние до игрока
func get_distance_to_player() -> float:
	return boss.global_position.distance_to(boss.player.global_position)

# Угол до игрока (в радианах)
func get_angle_to_player() -> float:
	return boss.global_position.angle_to_point(boss.player.global_position)

# Направление до точки
func get_direction_to(point: Vector2) -> Vector2:
	return (point - boss.global_position).normalized()

# Угол до точки
func get_angle_to(point: Vector2) -> float:
	return boss.global_position.angle_to_point(point)

# Вектор, повернутый на угол (в градусах)
func get_offset_direction(base: Vector2, angle_deg: float) -> Vector2:
	var angle_rad = deg_to_rad(angle_deg)
	return base.rotated(angle_rad)

# Перпендикулярный вектор
func get_perpendicular(dir: Vector2) -> Vector2:
	return Vector2(-dir.y, dir.x)
