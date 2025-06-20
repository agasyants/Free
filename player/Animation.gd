extends Node
class_name AnimationComponent
## Компонент поворота персонажа
## Отвечает за поворот всего тела персонажа (CharacterBody2D)

# Настройки поворота
@export var rotation_speed: float = 12.0  # Скорость плавного поворота
@export var use_smooth_rotation: bool = true  # Плавный или мгновенный поворот

# Настройки мигания
@export var blink_duration: float = 0.1  # Длительность одного мигания
@export var sprite_path: String = "Sprite2D"  # Путь к спрайту

# Внутренние переменные
var target_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.RIGHT

# Переменные для мигания
var is_blinking: bool = false
var blink_timer: float = 0.0
var blink_total_time: float = 0.0
var sprite_visible: bool = true

# Ссылка на узлы
@onready var body: CharacterBody2D = get_parent().get_parent()
@onready var sprite: Sprite2D = body.get_node(sprite_path) if sprite_path != "" else null

func handle_animation(delta: float):
	if target_direction != Vector2.ZERO:
		_apply_rotation(target_direction, delta)
	
	if is_blinking:
		_handle_blink(delta)

func set_direction(direction: Vector2) -> void:
	"""Устанавливает направление для поворота"""
	if direction != Vector2.ZERO:
		target_direction = direction
		last_direction = direction

func rotate_to_direction(direction: Vector2) -> void:
	"""Мгновенно поворачивает в указанном направлении"""
	if direction == Vector2.ZERO:
		return
	
	body.rotation = direction.angle()
	last_direction = direction

func stop_rotation() -> void:
	"""Останавливает поворот"""
	target_direction = Vector2.ZERO

func get_current_direction() -> Vector2:
	"""Возвращает текущее направление поворота"""
	return Vector2.from_angle(body.rotation)

func get_last_direction() -> Vector2:
	"""Возвращает последнее установленное направление"""
	return last_direction

func _apply_rotation(direction: Vector2, delta: float) -> void:
	"""Применяет поворот тела"""
	var target_angle = direction.angle()
	
	if use_smooth_rotation:
		body.rotation = lerp_angle(body.rotation, target_angle, rotation_speed * delta)
	else:
		body.rotation = target_angle

# Дополнительные утилиты
func is_facing_direction(direction: Vector2, tolerance: float = 0.1) -> bool:
	"""Проверяет, смотрит ли персонаж в указанном направлении"""
	var current_dir = get_current_direction()
	return current_dir.angle_to(direction) < tolerance

func set_rotation_speed(speed: float) -> void:
	"""Изменяет скорость поворота"""
	rotation_speed = speed

func set_smooth_rotation(smooth: bool) -> void:
	"""Включает/выключает плавный поворот"""
	use_smooth_rotation = smooth

# Функции мигания
func start_blink(duration: float) -> void:
	"""Запускает мигание спрайта на указанное время"""
	if not sprite:
		return
	
	is_blinking = true
	blink_total_time = duration
	blink_timer = 0.0
	sprite_visible = true

func stop_blink() -> void:
	"""Останавливает мигание и возвращает видимость спрайта"""
	if not sprite:
		return
	
	is_blinking = false
	blink_timer = 0.0
	blink_total_time = 0.0
	sprite.visible = true

func _handle_blink(delta: float) -> void:
	"""Обрабатывает логику мигания"""
	blink_total_time -= delta
	blink_timer -= delta
	
	# Переключаем видимость
	if blink_timer <= 0.0:
		blink_timer = blink_duration
		sprite_visible = not sprite_visible
		sprite.visible = sprite_visible
	
	# Заканчиваем мигание
	if blink_total_time <= 0.0:
		stop_blink()
