extends Camera2D
class_name Camera

@export var offset_factor := 0.4
@export var smoothing_speed := 5.0
@export var zoom_smoothing_speed := 4.0
@export var min_zoom := 0.1
@export var max_zoom := 1.0

@onready var player: CharacterBody2D = null
@onready var boss: CharacterBody2D = null

var visible_rect_world := Rect2() # кэш
var aspect_correction := Vector2.ONE

func _ready():
	player = get_tree().get_nodes_in_group("player").front()
	boss = get_tree().get_nodes_in_group("enemies").front() if get_tree().has_group("enemies") else null

func _process(delta):
	if player == null:
		return
		
	if boss == null:
		boss = player
	
	# --- Плавное смещение камеры ---
	var player_pos = player.global_position
	var boss_pos = boss.global_position
	var off = boss_pos - player_pos
	var target_pos = player_pos + off * offset_factor
	global_position = global_position.lerp(target_pos, delta * smoothing_speed)

	# --- Плавный зум ---
	var margin := 120.0
	var distance_x = abs(target_pos.x - boss_pos.x) * 2
	var distance_y = abs(target_pos.y - boss_pos.y) * 2
	var screen_size = get_viewport_rect().size
	var required_zoom_x = screen_size.x / (distance_x + margin * 2.0)
	var required_zoom_y = screen_size.y / (distance_y + margin * 2.0)
	var target_zoom_val = clamp(min(required_zoom_x, required_zoom_y), min_zoom, max_zoom)
	var target_zoom = Vector2(target_zoom_val, target_zoom_val)
	zoom = zoom.lerp(target_zoom, delta * zoom_smoothing_speed)

	# --- Кэш прямоугольника экрана в мировых координатах ---
	var half_extents = (screen_size * 0.5) / zoom
	visible_rect_world = Rect2(global_position - half_extents, half_extents * 2.0)

func is_visible_in_camera(point: Vector2, radius: float = 0.0) -> bool:
	return visible_rect_world.grow(radius).has_point(point)

func get_laser_clipped_point_optimized(origin: Vector2, direction: Vector2) -> Vector2:
	if direction.length_squared() < 0.0001:
		return origin
	if not visible_rect_world.has_point(origin):
		return origin
	
	direction = direction.normalized()
	var bounds := visible_rect_world
	var min_t := INF
	var hit_point := Vector2.ZERO
	
	# Проверяем только нужные стороны по направлению
	if direction.x > 0.00001:  # идем вправо
		var t = (bounds.position.x + bounds.size.x - origin.x) / direction.x
		if t > 0:
			var y = origin.y + direction.y * t
			if y >= bounds.position.y and y <= bounds.position.y + bounds.size.y:
				if t < min_t:
					min_t = t
					hit_point = Vector2(bounds.position.x + bounds.size.x, y)
	if direction.x < -0.00001:  # идем влево
		var t = (bounds.position.x - origin.x) / direction.x
		if t > 0:
			var y = origin.y + direction.y * t
			if y >= bounds.position.y and y <= bounds.position.y + bounds.size.y:
				if t < min_t:
					min_t = t
					hit_point = Vector2(bounds.position.x, y)
	
	if direction.y > 0.00001:  # идем вниз
		var t = (bounds.position.y + bounds.size.y - origin.y) / direction.y
		if t > 0:
			var x = origin.x + direction.x * t
			if x >= bounds.position.x and x <= bounds.position.x + bounds.size.x:
				if t < min_t:
					min_t = t
					hit_point = Vector2(x, bounds.position.y + bounds.size.y)
	
	if direction.y < -0.00001:  # идем вверх
		var t = (bounds.position.y - origin.y) / direction.y
		if t > 0:
			var x = origin.x + direction.x * t
			if x >= bounds.position.x and x <= bounds.position.x + bounds.size.x:
				if t < min_t:
					min_t = t
					hit_point = Vector2(x, bounds.position.y)
	
	return hit_point if min_t != INF else origin + direction * 10000.0
