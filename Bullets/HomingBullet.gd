extends Bullet
class_name HomingBullet
## Пуля с наводкой на цель (например, на игрока или босса)

@export var homing_strength: float = 5.0
@export var player_target_group: String = "enemies"
@export var enemy_target_group: String = "player"

var target: Node2D = null

func _ready() -> void:
	super()
	_find_target()

func _physics_process(delta: float) -> void:
	if target and is_instance_valid(target):
		var desired_dir = (target.global_position - global_position).normalized()
		velocity = velocity.lerp(desired_dir, clamp(homing_strength * delta, 0.0, 1.0)).normalized()

	super(delta)

func _find_target() -> void:
	var group = player_target_group if is_player else enemy_target_group
	for node in get_tree().get_nodes_in_group(group):
		if node is Node2D:
			target = node
			break

func parry() -> void:
	is_player = true
	var boss = get_tree().get_nodes_in_group("enemies").front()
	velocity = (boss.global_position - global_position).normalized()
	speed *= 1.5
	_find_target()
