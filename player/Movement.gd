extends Node
class_name MovementComponent

## Компонент движения игрока
## Отвечает за обработку ввода и расчет скорости движения

# Последнее направление движения (для стрельбы)
var last_movement_direction: Vector2 = Vector2.RIGHT
var current_speed: float = 0.0
var target_speed: float = 0.0
var acceleration_time: float = 0.0

# Ссылка на родительский CharacterBody2D
@onready var body: CharacterBody2D = get_parent().get_parent()

func handle(delta: float) -> void:
	var input_vector = get_input_vector()
	body.animation_component.set_direction(input_vector)
	
	# Запоминаем последнее направление движения
	if input_vector != Vector2.ZERO:
		last_movement_direction = input_vector
	
	# Определяем целевую скорость в зависимости от состояния
	if body.can_move():
		target_speed = types.state_speeds.get(body.state, 0.0)
		acceleration_time = types.state_accelerations.get(body.state, 0.0)
	else:
		target_speed = 0.0
	
	# Плавно изменяем текущую скорость к целевой
	if acceleration_time > 0:
		current_speed = move_toward(current_speed, target_speed, (target_speed/acceleration_time) * delta)
	else:
		current_speed = target_speed
	
	# Применяем движение
	if input_vector != Vector2.ZERO:
		body.velocity = input_vector * current_speed
	else:
		body.velocity = Vector2.ZERO

func get_input_vector() -> Vector2:
	"""Получает нормализованный вектор ввода от игрока"""
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

func get_last_direction() -> Vector2:
	"""Возвращает последнее направление движения"""
	return last_movement_direction
