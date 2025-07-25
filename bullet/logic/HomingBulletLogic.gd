extends BulletLogic
class_name HomingBulletLogic
## Пуля с наводкой на цель (например, на игрока или босса)

@export var homing_strength: float = 2.0
@export var player_target_group: String = "enemies"
@export var enemy_target_group: String = "player"

func update(bullet: BulletData, delta: float) -> void:
	var desired_dir
	if bullet.is_player and bullet.boss:
		desired_dir = (bullet.boss.global_position - bullet.position).normalized()
	else:
		desired_dir = (bullet.player.global_position - bullet.position).normalized()
	bullet.velocity = bullet.velocity.lerp(desired_dir, clamp(homing_strength * delta, 0.0, 1.0)).normalized()
	super.update(bullet, delta)
