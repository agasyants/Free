extends Node2D
class_name BossAnimationComponent

## Визуальный компонент босса
## Отвечает за отрисовку и реакцию на урон
## Используется как базовый класс для наследования

var damage_flash_timer: float = 0.0
const DAMAGE_FLASH_DURATION := 0.12
var damaged: bool = false

@onready var boss: Boss  = get_parent().get_parent()

func _ready() -> void:
	boss.get_node("Components/BossHealthComponent").damage_taken.connect(_on_damaged)

func _on_damaged(_amount: float) -> void:
	damage_flash_timer = DAMAGE_FLASH_DURATION

func update(delta: float) -> void:
	if damage_flash_timer > 0.0:
		damage_flash_timer -= delta
		damaged = true
	else:
		damaged = false
	queue_redraw()

func _draw() -> void:
	var fill_color := Color.RED if damaged else Color.BLACK
	var stroke_color := Color.RED if damaged else Color.RED
	
	var t = clamp(damage_flash_timer / DAMAGE_FLASH_DURATION, 0.0, 1.0)
	var s = 1.0 + t * 0.1
	var radius = 28.0 * s
	var w = 3.0 * s

	# тело
	draw_circle(Vector2.ZERO, radius, fill_color, true, -1, Settings.is_aa())
	draw_circle(Vector2.ZERO, radius, stroke_color, false, w, Settings.is_aa())
