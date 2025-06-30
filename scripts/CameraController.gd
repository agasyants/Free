extends Camera2D

@export var offset_factor := 0.3
@export var smoothing_speed := 5.0
@export var zoom_smoothing_speed := 5.0

@export var desired_distance := 600.0
@export var min_zoom := 0.1
@export var max_zoom := 1.0

@onready var player: CharacterBody2D = null
@onready var boss: CharacterBody2D = null

func _ready():
	player = get_tree().get_nodes_in_group("player").front()
	boss = get_tree().get_nodes_in_group("enemies").front()

func _process(delta):
	if player == null or boss == null:
		return

	# 1. Позиция
	var player_pos = player.global_position
	var boss_pos = boss.global_position
	var off = boss_pos - player_pos
	var target_pos = player_pos + off * offset_factor
	global_position = global_position.lerp(target_pos, delta * smoothing_speed)

	# 2. Зум 
	var margin := 50.0
	var distance = (target_pos - boss_pos).abs()
	var screen_size = get_viewport_rect().size
	var required_zoom_x = screen_size.x / (distance.x + margin * 2.0) / 2
	var required_zoom_y = screen_size.y / (distance.y + margin * 2.0) / 2
	var target_zoom_val = clamp(min(required_zoom_x, required_zoom_y), 0.2, 1.0)
	var target_zoom = Vector2(target_zoom_val, target_zoom_val)
	zoom = zoom.lerp(target_zoom, delta * zoom_smoothing_speed)
