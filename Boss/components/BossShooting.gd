extends Node
class_name BossShootingComponent

signal shot_fired(projectile: Node2D)

var boss: CharacterBody2D
@export var projectile_scene: PackedScene
var shoot_points: Array[Node2D] = []

func _ready():
	boss = get_parent().get_parent() as CharacterBody2D
	_find_shoot_points()

func _find_shoot_points():
	shoot_points.clear()
	for child in boss.get_children():
		if child.name.begins_with("ShootPoint"):
			shoot_points.append(child)

func set_projectile_scene(scene: PackedScene):
	projectile_scene = scene

func shoot_at_position(target_pos: Vector2, from_point: int = 0):
	if not projectile_scene:
		return
	
	var shoot_point = _get_shoot_point(from_point)
	if not shoot_point:
		return
	
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.call_deferred("add_child", projectile)
	projectile.global_position = shoot_point.global_position
	
	var direction = (target_pos - shoot_point.global_position).normalized()
	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)
	
	shot_fired.emit(projectile)

func shoot_at_player(player: Node2D, from_point: int = 0):
	if player:
		shoot_at_position(player.global_position, from_point)

func _get_shoot_point(index: int) -> Node2D:
	if shoot_points.is_empty():
		return boss
	return shoot_points[index % shoot_points.size()]
