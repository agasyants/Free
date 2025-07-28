extends Camera2D
class_name Camera

# ——— Твоя логика камеры (оставлена как есть) ———
@export var offset_factor := 0.4
@export var smoothing_speed := 4.5
@export var zoom_smoothing_speed := 4.0
@export var min_zoom := 0.1
@export var max_zoom := 0.95
var smoothed_position := Vector2.ZERO

var visible_rect_world := Rect2()
var aspect_correction := Vector2.ONE

@onready var player: CharacterBody2D = null
@onready var boss: CharacterBody2D = null

# ——— Shake-система ———

class ShakeEffect:
	var strength: float
	var duration: float
	var frequency: float
	var direction: Vector2
	var snap: bool
	var aftershock: bool
	var randomness: float

	var timer: float = 0.0
	var time_since_last: float = 0.0
	var current_offset: Vector2 = Vector2.ZERO
	var stage: int = 0

	func _init(
		_strength := 1.0,
		_duration := 0.3,
		_frequency := 0.02,
		_direction := Vector2.ZERO,
		_snap := false,
		_aftershock := true,
		_randomness := 1.0
	):
		strength = _strength
		duration = _duration
		frequency = _frequency
		direction = _direction
		snap = _snap
		aftershock = _aftershock
		randomness = clampf(_randomness, 0.0, 1.0)

	func update(delta: float) -> Vector2:
		timer += delta
		time_since_last += delta

		if timer >= duration:
			return Vector2.ZERO

		# Stage 0 — SNAP удар
		if snap and stage == 0:
			stage = 1
			return direction.normalized() * strength * 1.5

		# Stage 1+ — осцилляции
		if time_since_last >= frequency:
			time_since_last = 0.0
			var base_dir = direction
			if base_dir == Vector2.ZERO or randomness > 0.0:
				var angle_offset = randf_range(-PI, PI) * randomness
				base_dir = base_dir.rotated(angle_offset) if base_dir != Vector2.ZERO else Vector2.RIGHT.rotated(randf_range(0.0, TAU))
			var magnitude = strength * (1.0 - timer / duration)
			current_offset = base_dir.normalized() * magnitude

		return current_offset if aftershock or not snap else Vector2.ZERO


var active_shakes: Array[ShakeEffect] = []
var shake_offset: Vector2 = Vector2.ZERO


func _ready():
	player = get_tree().get_nodes_in_group("player").front()
	boss = get_tree().get_nodes_in_group("enemies").front() if get_tree().has_group("enemies") else null
	smoothed_position = global_position

func _process(delta: float):
	_update_shakes(delta)

	if player == null:
		return

	if boss == null:
		boss = player

	# ——— Плавное позиционирование + shake ———
	var player_pos = player.global_position
	var boss_pos = boss.global_position
	var off = boss_pos - player_pos
	var target_pos = player_pos + off * offset_factor
	# 1. плавно двигаем камеру к нужной позиции
	smoothed_position = smoothed_position.lerp(target_pos, delta * smoothing_speed)

	# 2. прибавляем shake отдельно
	global_position = smoothed_position + shake_offset

	# ——— Зум камеры ———
	var margin := 200.0
	var distance_x = abs(target_pos.x - boss_pos.x) * 2
	var distance_y = abs(target_pos.y - boss_pos.y) * 2
	var screen_size = get_viewport_rect().size
	var required_zoom_x = screen_size.x / (distance_x + margin * 2.0)
	var required_zoom_y = screen_size.y / (distance_y + margin * 2.0)
	var target_zoom_val = clamp(min(required_zoom_x, required_zoom_y), min_zoom, max_zoom)
	var target_zoom = Vector2(target_zoom_val, target_zoom_val)
	zoom = zoom.lerp(target_zoom, delta * zoom_smoothing_speed)

	# ——— Кэш видимой области ———
	var half_extents = (screen_size * 0.5) / zoom
	visible_rect_world = Rect2(global_position - half_extents, half_extents * 2.0)

func is_visible_in_camera(point: Vector2, radius: float = 0.0) -> bool:
	return visible_rect_world.grow(radius).has_point(point)

# ———————————————————————
# 🎥 SHAKE SYSTEM
# ———————————————————————

func add_shake(
	strength: float = 1.0,
	duration: float = 0.3,
	frequency: float = 0.02,
	direction: Vector2 = Vector2.ZERO,
	snap: bool = false,
	aftershock: bool = true,
	randomness: float = 1.0
):
	var shake := ShakeEffect.new(strength, duration, frequency, direction, snap, aftershock, randomness)
	active_shakes.append(shake)


func _update_shakes(delta: float):
	var total := Vector2.ZERO
	for shake in active_shakes:
		total += shake.update(delta)
	active_shakes = active_shakes.filter(func(s): return s.timer < s.duration)
	shake_offset = total


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
