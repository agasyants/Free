extends Node
class_name HealthComponent
## Компонент здоровья персонажа
## Отвечает за здоровье, получение урона и i-фреймы (неуязвимость)

# Настройки здоровья
@export var max_health: float = 100
@export var current_health: float = 100

@export var max_extra_lives: int = 3
@export var extra_lives: int = 3

@export var invincibility_duration: float = 0.6
@export var is_healing: bool = false

signal health_changed(current_health: int, max_health: int)
signal damage_taken(damage: int, remaining_health: int)
signal health_depleted
signal invincibility_started
signal invincibility_ended
signal player_knocked

var is_invincible: bool = false
var invincibility_timer: float = 0.0

@onready var body: Node = get_parent().get_parent()
@onready var animation_component: AnimationComponent = body.get_node("AnimationComponent") if body.has_node("AnimationComponent") else null

func _ready():
	current_health = max_health
	var hp_bar = get_node("/root/Node2D/CanvasLayer/PlayerHealthBar")
	if hp_bar:
		health_changed.connect(hp_bar.update_hp)
	emit_signal("health_changed", current_health, max_health)

func _process(delta: float):
	if is_invincible:
		_handle_invincibility(delta)
	if is_healing:
		healing(delta)

func take_damage(damage: float) -> bool:
	"""Наносит урон персонажу. Возвращает true, если урон был нанесен"""
	if is_invincible or damage <= 0 or body.state == types.PlayerState.DASH or is_healing:
		return false
	
	current_health = max(0.0, current_health - damage)
	
	# Испускаем сигналы
	health_changed.emit(current_health, max_health)
	damage_taken.emit(damage, current_health)
	
	# Запускаем i-фреймы
	_start_invincibility()
	
	# Проверяем, не умер ли персонаж
	if current_health <= 0 and Settings.can_die():
		extra_lives -= 1
		if extra_lives <= 0:
			health_depleted.emit()
		else:
			player_knocked.emit()
		
	Input.vibrate_handheld(200, 0.5)
	return true

func healing(delta: float) -> void:
	var healing_rate: float = 20.0  # Скорость восстановления здоровья в единицах в секунду
	current_health = clamp(current_health + healing_rate * delta, 0.0, max_health)
	
	health_changed.emit(current_health, max_health)

func heal(amount: float) -> void:
	"""Восстанавливает здоровье"""
	if amount <= 0:
		return
	
	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	
	if current_health != old_health:
		health_changed.emit(old_health, current_health)

func set_health(new_health: float) -> void:
	"""Устанавливает здоровье напрямую"""
	current_health = clamp(new_health, 0, max_health)
	
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		health_depleted.emit()

func add_extra_lives(add: int):
	extra_lives = clamp(extra_lives+add, 0, max_extra_lives)

func set_max_health(new_max_health: float, heal_to_max: bool = false) -> void:
	"""Изменяет максимальное здоровье"""
	max_health = max(1.0, new_max_health)
	
	if heal_to_max:
		set_health(max_health)
	else:
		current_health = min(current_health, max_health)

func is_alive() -> bool:
	"""Проверяет, жив ли персонаж"""
	return current_health > 0

func is_at_full_health() -> bool:
	"""Проверяет, полное ли здоровье"""
	return current_health >= max_health

func get_health_percentage() -> float:
	"""Возвращает здоровье в процентах (0.0 - 1.0)"""
	return float(current_health) / float(max_health)

func _start_invincibility() -> void:
	"""Запускает режим неуязвимости"""
	if is_invincible:
		return
	
	is_invincible = true
	invincibility_timer = invincibility_duration
	
	# Запускаем мигание через компонент анимации
	#if body.animation_component:
		#body.animation_component.start_blink(invincibility_duration)
	
	invincibility_started.emit()

func _handle_invincibility(delta: float) -> void:
	"""Обрабатывает логику неуязвимости"""
	invincibility_timer -= delta
	
	# Заканчиваем неуязвимость
	if invincibility_timer <= 0.0:
		_end_invincibility()

func _end_invincibility() -> void:
	"""Заканчивает режим неуязвимости"""
	is_invincible = false
	invincibility_timer = 0.0
	
	# Останавливаем мигание через компонент анимации
	if animation_component:
		animation_component.stop_blink()
	
	invincibility_ended.emit()

# Дополнительные утилиты
func force_invincibility(duration: float) -> void:
	"""Принудительно активирует неуязвимость на указанное время"""
	invincibility_duration = duration
	_start_invincibility()

func end_invincibility_immediately() -> void:
	"""Немедленно заканчивает неуязвимость"""
	if is_invincible:
		_end_invincibility()

func set_invincibility_duration(duration: float) -> void:
	"""Изменяет длительность неуязвимости"""
	invincibility_duration = max(0.0, duration)
