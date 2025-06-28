extends Node
class_name BossShootComponent

@export var default_bullet_scene: PackedScene
@export var fast_bullet_scene: PackedScene
@export var heavy_bullet_scene: PackedScene

var boss: CharacterBody2D

func _ready():
	boss = get_parent().get_parent() as Node2D

# Запустить пулю
func shoot(origin: Vector2, direction: Vector2, speed: float, bullet_type: String = "default"):
	var bullet_scene = get_bullet(bullet_type)
	if bullet_scene == null:
		push_warning("Пуля типа '%s' не задана" % bullet_type)
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = origin
	if bullet.has_method("setup"):
		bullet.setup(direction.normalized(), speed)

# Вернуть нужный тип пули
func get_bullet(bullet_type: String) -> PackedScene:
	match bullet_type:
		"default":
			return default_bullet_scene
		"fast":
			return fast_bullet_scene
		"heavy":
			return heavy_bullet_scene
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
