extends Control
class_name PlayerLivesUI

@onready var life_container: HBoxContainer = $LifeContainer
var player: Player = null

var total_lives := 0
var current_lives := 0

func _ready():
	add_to_group("player_lives_ui")
	find_player()
	player.health_component.player_knocked.connect(set_current_lives)

func find_player():
	player = get_tree().get_first_node_in_group("player")
	if player:
		total_lives = player.health_component.max_extra_lives if "max_lives" in player else 3
		set_total_lives(total_lives)

func set_total_lives(count: int):
	for i in range(count):
		var icon = ColorRect.new()
		icon.color = Color.WHITE
		icon.custom_minimum_size = Vector2(16, 16)
		life_container.add_child(icon)

func set_current_lives():
	var count = player.health_component.extra_lives
	for i in range(life_container.get_child_count()):
		var icon = life_container.get_child(i) as ColorRect
		icon.color = Color.WHITE if i < count else Color.BLACK
