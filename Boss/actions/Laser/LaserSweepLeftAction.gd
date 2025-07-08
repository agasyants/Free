extends BossAction
class_name LaserSweepLeftAction

var sweep_speed := 120.0
var aim_dir: Vector2

func _init():
	super()
	aim_dir = Vector2.ZERO

func update(delta: float) -> void:
	timer += delta

	if timer == delta:
		# Инициализация в первый кадр: направление на игрока +90°
		aim_dir = boss.laser.get_offset_direction_from_player(-120)

	# Плавный поворот по часовой
	if 0.1 <= timer and timer <= 2.2:
		aim_dir = boss.laser.rotate_direction_with_speed(aim_dir, delta, sweep_speed, false)

	if timer >= 2.2:
		boss.laser.fire_lasers([])
	else:
		boss.laser.fire_lasers([
			{
				"from": boss.global_position,
				"direction": aim_dir,
				"damage": 20.0,
				"color": Color.RED,
				"width": 40.0
			}
		])

	if timer >= 2.5:
		finished = true
