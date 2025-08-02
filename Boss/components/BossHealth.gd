extends Node
class_name BossHealthComponent

signal health_changed(current_health: int, max_health: int)
signal boss_died
signal damage_taken(damage: int)

@onready var boss: Boss  = get_parent().get_parent()
var max_health: int = 100
var current_health: int
var is_invulnerable: bool = false

func _ready():
	current_health = max_health
	var hp_bar = get_node("/root/Node2D/CanvasLayer/BossHealthBar")
	if hp_bar:
		health_changed.connect(hp_bar.update_hp)
	emit_signal("health_changed", current_health, max_health)

func take_damage(damage: int, power: float, type: String, direction: Vector2):
	if is_invulnerable or current_health <= 0:
		return
	
	current_health = max(0, current_health - damage)
	damage_taken.emit(damage)
	health_changed.emit(current_health, max_health)
	
	var camera: Camera = get_viewport().get_camera_2d()
	
	if power > 1:
		boss.movement.add_recoil(direction, 200 * (power-1))
	
	if type == "melee":
		camera.add_shake(6, 0.25, 0.01, Vector2.ZERO, true, true, 2.0)
		
		Engine.time_scale = 0.0
		await owner.get_tree().create_timer(0.08, false, false, true).timeout
		Engine.time_scale = 1.0
	else:
		camera.add_shake(1.5, 0.5, 0.01, Vector2.ZERO, false, true, 1.0)
		
	
	if current_health <= 0:
		boss_died.emit()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func set_invulnerable(invulnerable: bool):
	is_invulnerable = invulnerable

func get_health_percentage() -> float:
	return float(current_health) / float(max_health)

func is_alive() -> bool:
	return current_health > 0

func die():
	print("Boss is dead.")
	var hp_bar = get_node("/root/Node2D/CanvasLayer/BossHealthBar")
	if hp_bar:
		hp_bar.hide()
	#emit_signal("died")
	boss.queue_free()
