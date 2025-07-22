# MainMenu.gd
extends Control

func _ready():
	$VBoxContainer/StartButton.pressed.connect(_on_play_button_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://menu/LevelSelect.tscn")
	
func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://menu/Settings.tscn")

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://menu/OptionsMenu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
