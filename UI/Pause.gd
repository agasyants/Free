extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_button_pressed)
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_button_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
	hide()

func _on_resume_button_pressed():
	resume()

func _on_settings_button_pressed():
	resume()
	get_tree().change_scene_to_file("res://menu/Settings.tscn")

func _on_restart_button_pressed():
	resume()
	get_tree().reload_current_scene()
	
func _on_quit_button_pressed():
	resume()
	get_tree().change_scene_to_file("res://menu/LevelSelect.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause()

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		pause()

func resume():
	get_tree().paused = false
	hide()
	
func pause():
	get_tree().paused = true
	show()
