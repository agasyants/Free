extends Node
class_name BoundaryComponent

## Компонент ограничения границ экрана
## Отвечает за удержание объекта в пределах экрана

@export var use_sprite_bounds: bool = true
@export var custom_margin: Vector2 = Vector2.ZERO

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
	if not use_sprite_bounds:
		return Vector2.ZERO
	
	var sprite_size = Vector2.ZERO
	
	# Пробуем найти Sprite2D
	if body.has_node("Sprite2D"):
		var sprite = body.get_node("Sprite2D") as Sprite2D
		if sprite and sprite.texture:
			sprite_size = sprite.texture.get_size() * sprite.scale / 2
	
	# Если не найден Sprite2D, пробуем AnimatedSprite2D
	elif body.has_node("AnimatedSprite2D"):
		var animated_sprite = body.get_node("AnimatedSprite2D") as AnimatedSprite2D
		sprite_size = get_animated_sprite_size(animated_sprite)
	
	return sprite_size

func get_animated_sprite_size(animated_sprite: AnimatedSprite2D) -> Vector2:
	"""Получает размер AnimatedSprite2D"""
	if not animated_sprite or not animated_sprite.sprite_frames:
		return Vector2.ZERO
	
	if not animated_sprite.sprite_frames.has_animation(animated_sprite.animation):
		return Vector2.ZERO
	
	var texture = animated_sprite.sprite_frames.get_frame_texture(
		animated_sprite.animation, 
		animated_sprite.frame
	)
	
	if texture:
		return texture.get_size() * animated_sprite.scale / 2
	
	return Vector2.ZERO

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
