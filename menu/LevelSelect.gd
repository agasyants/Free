# LevelSelect.gd
extends Control

var levels = [
	{"name": "Boss", "path": "res://levels/Main.tscn"},
	{"name": "Test", "path": "res://levels/test.tscn"},
	{"name": "Easy", "path": "res://levels/Easy.tscn"},
]

func _ready():
	$BackButton.pressed.connect(_on_back_button_pressed)
	for i in range(levels.size()):
		var button = Button.new()
		button.text = levels[i]["name"]
		button.custom_minimum_size = Vector2(200, 60)

		# Обычное состояние: белая кнопка, чёрный текст
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color("#f0f0f0")

		# При наведении: чёрная кнопка с белой обводкой
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color("#0f0f0f")
		hover_style.border_width_left = 2
		hover_style.border_width_right = 2
		hover_style.border_width_top = 2
		hover_style.border_width_bottom = 2
		hover_style.border_color = Color("#f0f0f0")

		# При нажатии: то же что и при наведении
		var pressed_style = hover_style.duplicate()

		# Применяем стили
		button.add_theme_stylebox_override("normal", normal_style)
		button.add_theme_stylebox_override("hover", hover_style)
		button.add_theme_stylebox_override("pressed", pressed_style)

		# Цвета текста
		button.add_theme_color_override("font_color", Color("#0f0f0f"))         # Обычный
		button.add_theme_color_override("font_hover_color", Color("#f0f0f0"))   # При наведении
		button.add_theme_color_override("font_pressed_color", Color("#f0f0f0")) # При нажатии

		# Размер шрифта
		button.add_theme_font_size_override("font_size", 32)

		button.pressed.connect(_on_level_button_pressed.bind(i))
		$GridContainer.add_child(button)
	$BackButton.grab_focus()

func _on_level_button_pressed(index):
	get_tree().change_scene_to_file(levels[index]["path"])

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://menu/Menu.tscn")
