extends Node
class_name BoundaryComponent

## Компонент ограничения границ арены (круг)
## Отвечает за удержание объекта в пределах круга

@export var use_sprite_bounds: bool = true
@export var custom_margin: float = 0.0  # Дополнительный отступ от границы
@onready var arena: Arena = get_node("/root/Node2D/Arena") # Предполагается, что Arena имеет `radius` и `position`

# Ссылка на родительский узел (например, игрока)
@onready var body: Node2D = get_parent().get_parent()

func clamp_to_arena() -> void:
	"""Ограничивает позицию объекта границами круговой арены"""
	if !arena:
		push_error("Arena not set in BoundaryComponent!")
		return
	
	var sprite_radius = get_sprite_radius() if use_sprite_bounds else 0.0
	var max_radius = arena.radius - sprite_radius - custom_margin
	
	var direction = (body.global_position - arena.position).normalized()
	var distance = arena.position.distance_to(body.global_position)
	
	if distance > max_radius:
		body.global_position = arena.position + direction * max_radius

func get_sprite_radius() -> float:
	"""Получает радиус спрайта (если объект круглый)"""
	if body is Node2D and body.has_method("get_radius"):
		return body.get_radius()
	elif "radius" in body:  # Проверяем, есть ли свойство radius
		return body.radius
	else:
		return 0.0

func is_within_bounds(position: Vector2) -> bool:
	"""Проверяет, находится ли позиция в пределах арены"""
	if !arena:
		return false
	
	var sprite_radius = get_sprite_radius() if use_sprite_bounds else 0.0
	var max_radius = arena.radius - sprite_radius - custom_margin
	
	return arena.position.distance_to(position) <= max_radius

func get_arena_bounds() -> Dictionary:
	"""Возвращает параметры арены (центр и радиус)"""
	if !arena:
		return {}
	
	var sprite_radius = get_sprite_radius() if use_sprite_bounds else 0.0
	var effective_radius = arena.radius - sprite_radius - custom_margin
	
	return {
		"center": arena.position,
		"radius": effective_radius
	}
