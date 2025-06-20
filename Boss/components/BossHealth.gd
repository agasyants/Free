extends Node
class_name BossHealthComponent

signal health_changed(current_health: int, max_health: int)
signal boss_died
signal damage_taken(damage: int)

var boss: CharacterBody2D
var max_health: int = 100
var current_health: int
var is_invulnerable: bool = false

func _ready():
	current_health = max_health
	var hp_bar = get_node("/root/Node2D/CanvasLayer/BossHealthBar")
	if hp_bar:
		health_changed.connect(hp_bar.update_hp)
	emit_signal("health_changed", current_health, max_health)
	boss = get_parent().get_parent() as CharacterBody2D

func take_damage(damage: int):
	if is_invulnerable or current_health <= 0:
		return
	
	current_health = max(0, current_health - damage)
	damage_taken.emit(damage)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()
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
