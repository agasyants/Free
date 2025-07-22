extends Control

# Конфигурация настроек с типами элементов и параметрами
var setting_controls = {}  # Словарь для хранения ссылок на элементы управления

func _ready():
	# Настройка кнопки возврата
	$BackButton.pressed.connect(_on_back_button_pressed)
	
	# Создаем контейнер для настроек
	var settings_container = $VBoxContainer
	
	# Генерируем элементы управления для каждой настройки
	for setting_key in Settings.CONFIG:
		var config = Settings.CONFIG[setting_key]
		var current_value = Settings.settings[setting_key]
		
		# Создаем контейнер для строки настройки
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		settings_container.add_child(hbox)
		
		# Добавляем метку
		var label = Label.new()
		label.text = config["label"] + ":"
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(label)
		
		# Создаем элемент управления в зависимости от типа
		var control
		if config["type"] == "option":
			var option_button = OptionButton.new()
			for option in config["options"]:
				# Форматируем значение при необходимости
				var display_text = config.get("format_value", func(val): return str(val)).call(option)
				option_button.add_item(display_text)
			
			# Устанавливаем текущее значение
			var index = config["options"].find(current_value)
			if index >= 0:
				option_button.select(index)
			
			control = option_button
		elif config["type"] == "checkbox":
			var checkbox = CheckBox.new()
			checkbox.button_pressed = current_value
			control = checkbox
		
		# Сохраняем ссылку на элемент
		setting_controls[setting_key] = control
		hbox.add_child(control)
	
	# Добавляем кнопку сохранения
	var save_button = Button.new()
	save_button.text = "Save and Apply"
	save_button.pressed.connect(_on_save_and_apply_pressed)
	settings_container.add_child(save_button)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://menu/Menu.tscn")

func _on_save_and_apply_pressed():
	# Обновляем настройки на основе элементов управления
	for setting_key in setting_controls:
		var control = setting_controls[setting_key]
		var config = Settings.CONFIG[setting_key]
		
		if config["type"] == "option":
			var selected_index = control.selected
			Settings.settings[setting_key] = config["options"][selected_index]
		elif config["type"] == "checkbox":
			Settings.settings[setting_key] = control.button_pressed
	
	# Сохраняем и применяем изменения
	Settings.save_settings()
	Settings.apply_settings()
	get_tree().reload_current_scene()
