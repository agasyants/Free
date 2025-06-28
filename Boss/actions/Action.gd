extends Node
class_name BossAction

var boss: CharacterBody2D = null
var finished := false
var timer: float = 0.0

func _init() -> void:
	timer = 0.0

func update(delta: float) -> void:
	timer += delta
	# Override in subclass

func is_finished() -> bool:
	return finished
