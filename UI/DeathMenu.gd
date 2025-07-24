extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_button_pressed)
	$VBoxContainer/LevelsButton.pressed.connect(_on_levels_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
	hide()
	var players = get_tree().get_nodes_in_group("player")
	var player  = players[0] if players.size() > 0 else null
	player.health_component.health_depleted.connect(player_died)

func _on_levels_button_pressed():
	resume()
	get_tree().change_scene_to_file("res://menu/LevelSelect.tscn")

func _on_restart_button_pressed():
	resume()
	get_tree().reload_current_scene()
	
func _on_quit_button_pressed():
	resume()
	get_tree().change_scene_to_file("res://menu/Menu.tscn")

func resume():
	get_tree().paused = false
	hide()
	
func player_died():
	get_tree().paused = true
	show()
