extends Node
class_name BossMovementComponent

var boss: CharacterBody2D
var speed: float = 100.0

func _ready():
	boss = get_parent().get_parent() as CharacterBody2D

func move_to_position(pos: Vector2, move_speed: float = -1):
	var move_speed_final = speed if move_speed <= 0 else move_speed
	var direction = (pos - boss.global_position).normalized()
	boss.velocity = direction * move_speed_final
	boss.move_and_slide()

func move_to_player(player: Node2D, move_speed: float = -1):
	if player:
		move_to_position(player.global_position, move_speed)

func stop_movement():
	boss.velocity = Vector2.ZERO

func look_at_position(pos: Vector2):
	var direction = pos - boss.global_position
	boss.rotation = direction.angle()

func look_at_player(player: Node2D):
	if player:
		look_at_position(player.global_position)

func rotate_to_angle(angle: float):
	boss.rotation = angle

func get_distance_to_position(pos: Vector2) -> float:
	return boss.global_position.distance_to(pos)

func get_distance_to_player(player: Node2D) -> float:
	if player:
		return get_distance_to_position(player.global_position)
	return 0.0
