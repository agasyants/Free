extends Camera2D

@export var offset_factor := 0.4
@export var smoothing_speed := 5.0
@export var zoom_smoothing_speed := 4.0
@export var min_zoom := 0.1
@export var max_zoom := 1.0

@onready var player: CharacterBody2D = null
@onready var boss: CharacterBody2D = null
var aspect_correction := Vector2.ONE

func _ready():
	player = get_tree().get_nodes_in_group("player").front()
	boss = get_tree().get_nodes_in_group("enemies").front() if get_tree().has_group("enemies") else null

func _process(delta):
	if player == null:
		return
		
	if boss == null:
		boss = player
	
	# 1. Позиция
	var player_pos = player.global_position
	var boss_pos = boss.global_position
	var off = boss_pos - player_pos
	var target_pos = player_pos + off * offset_factor
	global_position = global_position.lerp(target_pos, delta * smoothing_speed)
	
	# 2. Зум с учетом aspect ratio
	var margin := 120.0
	var distance_x = abs(target_pos.x - boss_pos.x) * 2
	var distance_y = abs(target_pos.y - boss_pos.y) * 2
	var screen_size = get_viewport_rect().size
	var required_zoom_x = screen_size.x / (distance_x + margin * 2.0)
	var required_zoom_y = screen_size.y / (distance_y + margin * 2.0)
	
	var target_zoom_val = clamp(min(required_zoom_x, required_zoom_y), min_zoom, max_zoom)
	# Применяем aspect correction
	var target_zoom = Vector2(target_zoom_val, target_zoom_val)
	zoom = zoom.lerp(target_zoom, delta * zoom_smoothing_speed)
