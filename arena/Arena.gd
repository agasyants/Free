extends Node2D
class_name Arena

@export var radius := 800.0
@export var base_color := Color(0.05, 0.05, 0.05)
@export var grid_color := Color(0.15, 0.15, 0.15)
@export var accent_color := Color(0.3, 0.1, 0.1)
@export var border_color := Color(0.8, 0.8, 0.8)

func _ready():
	queue_redraw()
