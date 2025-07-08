extends BossAction
class_name DualLaserSweepAction

var duration := 2.0
var delay := 1.0
var sweep_speed := 90.0
var aim_dir1: Vector2
var aim_dir2: Vector2

func _init():
	super()
	aim_dir1 = Vector2.ZERO
	aim_dir2 = Vector2.ZERO

func update(delta: float) -> void:
	timer += delta

	if timer == delta:
		aim_dir1 = boss.laser.get_offset_direction_from_player(90)
		aim_dir2 = boss.laser.get_offset_direction_from_player(-90)
	
	if timer >= 0.1:
		aim_dir1 = boss.laser.rotate_direction_with_speed(aim_dir1, delta, sweep_speed, true)
		aim_dir2 = boss.laser.rotate_direction_with_speed(aim_dir2, delta, sweep_speed, false)

	if duration >= timer:
		boss.laser.fire_lasers([
			{
				"from": boss.global_position,
				"direction": aim_dir1,
				"damage": 10.0,
				"color": Color.ORANGE,
				"width": 30.0
			},
			{
				"from": boss.global_position,
				"direction": aim_dir2,
				"damage": 10.0,
				"color": Color.CYAN,
				"width": 30.0
			}
		])
	else:
		boss.laser.fire_lasers([])

	if timer >= duration + delay:
		finished = true
