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
@onready var move_stick := get_node("/root/Node2D/CanvasLayer/LeftStick")

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
		if body.damaged_time > 0:
			body.velocity = input_vector * current_speed / 3
		else:
			body.velocity = input_vector * current_speed
	else:
		body.velocity = Vector2.ZERO
	_process_recoil(delta)

func get_input_vector() -> Vector2:
	"""Получает нормализованный вектор движения от стика или клавиш"""
	if move_stick.get_vector().length() > 0.1:
		return move_stick.get_vector().normalized()
	else:
		return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
 
# Переменные для отдачи
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

		body.velocity += recoil_velocity

		if recoil_velocity.length() < min_recoil:
			recoil_velocity = Vector2.ZERO

func get_last_direction() -> Vector2:
	"""Возвращает последнее направление движения"""
	return last_movement_direction
