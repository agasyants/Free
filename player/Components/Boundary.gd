extends Node
class_name BoundaryComponent

## Компонент ограничения границ экрана
## Отвечает за удержание объекта в пределах экрана

@export var use_sprite_bounds: bool = true
@export var custom_margin: Vector2 = Vector2(-100,-100)

# Ссылка на родительский узел
@onready var body: Node2D = get_parent().get_parent()

func clamp_to_screen() -> void:
	"""Ограничивает позицию объекта границами экрана"""
	var screen_size = body.get_viewport_rect().size
	var sprite_size = get_sprite_size()
	
	var margin = sprite_size + custom_margin
	
	body.global_position.x = clamp(
		body.global_position.x, 
		margin.x, 
		screen_size.x - margin.x
	)
	body.global_position.y = clamp(
		body.global_position.y, 
		margin.y, 
		screen_size.y - margin.y
	)

func get_sprite_size() -> Vector2:
	"""Получает размер спрайта для правильного ограничения"""
	return Vector2(body.radius, body.radius)

func is_within_bounds(position: Vector2) -> bool:
	"""Проверяет, находится ли позиция в пределах экрана"""
	var screen_size = body.get_viewport_rect().size
	var sprite_size = get_sprite_size()
	var margin = sprite_size + custom_margin
	
	return position.x >= margin.x and position.x <= screen_size.x - margin.x and \
		   position.y >= margin.y and position.y <= screen_size.y - margin.y

func get_screen_bounds() -> Rect2:
	"""Возвращает границы экрана с учетом размера спрайта"""
	var screen_size = body.get_viewport_rect().size
	var sprite_size = get_sprite_size()
	var margin = sprite_size + custom_margin
	
	return Rect2(
		margin.x,
		margin.y,
		screen_size.x - margin.x * 2,
		screen_size.y - margin.y * 2
	)
