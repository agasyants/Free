extends Area2D
class_name BulletCollisionProxy

var bullet_data: BulletData
var manager: BulletManager
var is_active: bool = false

var original_collision_layer: int = 0
var original_collision_mask: int = 0

func _ready():
	connect("body_entered", _on_body_entered)
	connect("area_entered", _on_area_entered)
	# Сохраняем оригинальные настройки коллизии из сцены
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask
	$CollisionShape2D.shape.radius = 0

func activate(bullet: BulletData) -> void:
	bullet_data = bullet
	is_active = true
	visible = true
	change_owner()

func deactivate() -> void:
	bullet_data = null
	is_active = false
	visible = false
	collision_layer = 0  # Полностью отключаем коллизии
	collision_mask = 0   # Полностью отключаем маску

func change_owner():
	if bullet_data.is_player:
		collision_layer = 3
		collision_mask = 2
	else:
		collision_layer = 4
		collision_mask = 1

func set_radius(radius: float):
	if $CollisionShape2D:
		var new_shape := CircleShape2D.new()
		new_shape.radius = radius
		$CollisionShape2D.shape = new_shape

func _process(_delta: float) -> void:
	if is_active and bullet_data:
		global_position = bullet_data.position

func _on_body_entered(body: Node) -> void:
	if is_active and manager and bullet_data:
		manager.notify_body_entered(bullet_data, body)

func _on_area_entered(area: Area2D) -> void:
	if is_active and manager and bullet_data and area is BulletCollisionProxy:
		var other = area.bullet_data
		if other and area.is_active:  # Проверяем, что другая прокси тоже активна
			manager.notify_bullet_entered(bullet_data, other)
