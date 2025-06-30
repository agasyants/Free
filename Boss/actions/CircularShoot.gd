extends BossAction
class_name CircleAndShootAction

var duration := 2.0
var shoot_interval := 0.5
var shoot_timer := 0.0
var radius := 150.0
var angular_speed := 2.0
var center: Vector2

func update(delta: float):
	timer += delta
	shoot_timer += delta

	if timer == delta:
		center = boss.player.global_position

	# Расчёт позиции по окружности
	var angle = angular_speed * timer
	var offset = Vector2(cos(angle), sin(angle)) * radius
	var target = center + offset
	boss.movement.move_towards(target, 250)

	if shoot_timer >= shoot_interval:
		shoot_timer = 0.0
		var dir = boss.shoot.get_direction_to_player()
		boss.shoot.shoot(boss.global_position, dir)

	boss.movement.update(delta)
	#boss.shoot.update(delta)

	if timer >= duration:
		boss.movement.stop()
		finished = true
