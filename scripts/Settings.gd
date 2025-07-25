extends Node

var CONFIG = {
	"graphics": {
		#"quality_level": {
			#"label": "Quality Level",
			#"type": "option",
			#"options": ["low", "medium", "high"]
		#},
		"render_resolution": {
			"label": "Resolution",
			"type": "option",
			"options": ["480p", "720p", "native"]
		},
		#"bullet_draw_mode": {
			#"label": "Bullet Draw Mode",
			#"type": "option",
			#"options": ["normal", "minimal"]
		#},
		"gpu_antialiasing": {
			"label": "GPU Antialising",
			"type": "option",
			"options": ["off", "2x", "4x", "8x"]
		},
		"target_fps": {
			"label": "FPS Cap",
			"type": "option",
			"options": ["30", "60", "100"],
		},
		"vsync_enabled": {
			"label": "VSync",
			"type": "checkbox"
		},
		"enable_trails": {
			"label": "Enable Trails",
			"type": "checkbox"
		},
		"cpu_antialiasing_enabled": {
			"label": "Enable CPU Antialising",
			"type": "checkbox"
		},
	},
	
	"gameplay": {
		#"difficulty": {
			#"label": "Difficulty",
			#"type": "option",
			#"options": ["easy", "normal", "hard"]
		#},
		#"auto_aim": {
			#"label": "Auto Aim",
			#"type": "checkbox"
		#},
		#"camera_shake": {
			#"label": "Camera Shake",
			#"type": "checkbox"
		#},
		"diying": {
			"label": "Can You Die",
			"type": "checkbox"
		}
	},
	
	"controls": {
		#"keyboard_layout": {
			#"label": "Keyboard Layout",
			#"type": "option",
			#"options": ["QWERTY", "AZERTY", "DVORAK"]
		#},
		#"mouse_sensitivity": {
			#"label": "Mouse Sensitivity",
			#"type": "range",
			#"min": 0.1,
			#"max": 5.0,
			#"step": 0.1
		#},
		#"invert_y_axis": {
			#"label": "Invert Y Axis",
			#"type": "checkbox"
		#},
		"vibration": {
			"label": "Controller Vibration",
			"type": "checkbox"
		}
	}
}

const DEFAULTS = {
	# Graphics
	#"quality_level": "medium",
	"render_resolution": "native",
	"enable_trails": true,
	#"bullet_draw_mode": "normal",
	"target_fps": "60",
	"vsync_enabled": true,
	"cpu_antialiasing_enabled": false,
	"gpu_antialiasing": "2x",
	
	# Gameplay
	#"difficulty": "normal",
	#"auto_aim": false,
	#"camera_shake": true,
	"diying": true,
	
	# Controls
	#"keyboard_layout": "QWERTY",
	#"mouse_sensitivity": 1.0,
	#"invert_y_axis": false,
	"vibration": true
}

var settings = DEFAULTS.duplicate(true)
var _loaded := false

func _ready():
	load_settings()
	apply_settings()

func load_settings():
	var path = "user://settings.cfg"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var text = file.get_as_text()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			settings = DEFAULTS.duplicate(true)
			for key in parsed:
				if settings.has(key):
					settings[key] = parsed[key]
		print(settings)
	_loaded = true

func save_settings():
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	file.store_string(JSON.stringify(settings, "\t"))

func apply_settings():
	if not _loaded:
		return
	
	apply_graphics_settings()
	apply_gameplay_settings()
	apply_controls_settings()
	
func apply_graphics_settings():
	# FPS cap
	print(int(settings["target_fps"]))
	Engine.max_fps = int(settings["target_fps"])
	# VSync
	if settings["vsync_enabled"]:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# Render resolution (requires viewport stretch mode)
	var res = settings["render_resolution"]
	var size = Vector2i.ZERO
	match res:
		"480p":
			set_resolution("viewport", "keep")
			size = Vector2i(854, 480)
		"720p":
			set_resolution("viewport", "keep")
			size = Vector2i(1280, 720)
		"native":
			set_resolution("canvas_items", "expand")
			# Для native — просто оставим текущий экран
			size = DisplayServer.screen_get_size()
		_:
			size = DisplayServer.screen_get_size()

	ProjectSettings.set_setting("display/window/size/viewport_width", size.x)
	ProjectSettings.set_setting("display/window/size/viewport_height", size.y)

	# Resize desktop window too (optional)
	if OS.has_feature("pc"):
		DisplayServer.window_set_size(size)
		
	var aa = settings["gpu_antialiasing"]
	match aa:
		"off":
			set_msaa_level(0)
		"2x":
			set_msaa_level(1)
		"4x":
			set_msaa_level(2)
		"8x":
			set_msaa_level(3)

func set_resolution(mode:String, ascpect:String):
	ProjectSettings.set_setting("display/window/stretch/mode", mode)
	ProjectSettings.set_setting("display/window/stretch/aspect", ascpect)

func is_aa() -> bool:
	return settings["cpu_antialiasing_enabled"]

func is_trails() -> bool:
	return settings["enable_trails"]

func set_msaa_level(level: int):
	var msaa_modes = [
		RenderingServer.VIEWPORT_MSAA_DISABLED,
		RenderingServer.VIEWPORT_MSAA_2X,
		RenderingServer.VIEWPORT_MSAA_4X,
		RenderingServer.VIEWPORT_MSAA_8X
	]
	if level >= 0 and level < msaa_modes.size():
		RenderingServer.viewport_set_msaa_2d(get_tree().get_root().get_viewport_rid(), msaa_modes[level])

func apply_gameplay_settings():
	pass  # Здесь будет логика применения игровых настроек

func apply_controls_settings():
	pass  # Здесь будет логика применения настроек управления

func can_die():
	return settings["diying"]

func shake():
	return settings["vibration"]
