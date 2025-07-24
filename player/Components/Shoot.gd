extends Node
class_name ShootingComponent
## Компонент стрельбы игрока
## Отвечает за создание пуль и управление стрельбой

signal bullet_fired(bullet_position: Vector2, bullet_direction: Vector2)

@export var shoot_cooldown: float = 0.16

var shoot_cooldown_timer: float = 0.0

# Ссылки на узлы
@onready var body: CharacterBody2D = get_parent().get_parent()
@onready var muzzle: Marker2D = body.get_node("Muzzle")
@onready var aim_stick: VirtualStick = get_node("/root/Node2D/CanvasLayer/RightStick")
@onready var bullet_manager: BulletManager = get_node("/root/Node2D/BulletManager")

func _ready():
	validate_components()

func validate_components() -> void:
	"""Проверяет наличие всех необходимых компонентов"""
	if not body.has_node("Muzzle"):
		push_error("Muzzle node отсутствует! Добавьте Marker2D с именем 'Muzzle'")

func handle(delta: float) -> void:
	"""Основной метод обработки стрельбы"""
	update_cooldown_timer(delta)
	
	# Проверяем нажатие кнопки стрельбы
	var shoot_pressed = Input.is_action_pressed("shoot") or aim_stick.get_vector().length() > 0.1
	
	if shoot_pressed:
		if can_shoot():
			shoot()
			body.set_state(types.PlayerState.SHOOT)
		body.animation_component.set_direction(get_shoot_direction())
	else:
		# Обновляем состояние is_shooting
		if shoot_pressed and shoot_cooldown_timer > 0.0:
			body.set_state(types.PlayerState.SHOOT)
		elif body.state == types.PlayerState.SHOOT:
			body.set_state(types.PlayerState.IDLE)

func update_cooldown_timer(delta: float) -> void:
	"""Обновляет таймер кулдауна стрельбы"""
	if shoot_cooldown_timer > 0.0:
		shoot_cooldown_timer -= delta

func shoot() -> void:
	"""Создает пулю и выстреливает в направлении мыши"""
	var direction = get_shoot_direction()
	var bullet_position = muzzle.global_position
	
	create_bullet(bullet_position, direction)
	start_cooldown()
	bullet_fired.emit(bullet_position, direction)

func start_cooldown() -> void:
	"""Запускает кулдаун после выстрела"""
	shoot_cooldown_timer = shoot_cooldown

func create_bullet(position: Vector2, direction: Vector2) -> void:
	bullet_manager.spawn_bullet({
		"position": position,
		"velocity": direction,
		"speed": 600.0,
		"damage": 2,
		"health": 1,
		"radius": 6.0,
		"lifetime": 8.0,
		"is_player": true,
		"logic_id": "default",
		"renderer_id": "default"
	})

func get_shoot_direction() -> Vector2:
	"""Возвращает направление стрельбы (к позиции мыши или из стика)"""	
	if aim_stick.get_vector().length() > 0.1:
		return aim_stick.get_vector().normalized()
	else:
		var mouse_pos = body.get_global_mouse_position()
		return (mouse_pos - body.global_position).normalized()

func can_shoot() -> bool:
	"""Проверяет, может ли игрок стрелять"""
	return shoot_cooldown_timer <= 0.0 and !body.dash_component.is_dashing() and !body.dash_component.is_charging() and body.state != types.PlayerState.CHARGING_ATTACK and body.state != types.PlayerState.ATTACK and body.state != types.PlayerState.PARRY

func get_shoot_cooldown_progress() -> float:
	"""Возвращает прогресс кулдауна стрельбы (0.0 - 1.0)"""
	if shoot_cooldown_timer <= 0.0:
		return 1.0
	return 1.0 - (shoot_cooldown_timer / shoot_cooldown)

func is_shooting() -> bool:
	return body.state == types.PlayerState.SHOOT
