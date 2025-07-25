extends BulletRenderer
class_name HomingBulletRenderer

func update(bullet: BulletData, delta: float) -> void:
	bullet.time += delta

func draw_canvas(target: CanvasItem, bullet: BulletData) -> void:
	var t = bullet.time
	var pos = bullet.position
		
	var dark_red = Color("#000000")
	var glow_red = Color("#FFFF00")

	# Контур с резкой пульсацией
	var pulse = abs(sin(t * 25.0)) * 3.0
	target.draw_circle(pos, bullet.radius + pulse, dark_red, true, -1, Settings.is_aa())
	target.draw_circle(pos, bullet.radius + pulse, glow_red, false, 1.5 + pulse * 0.2, Settings.is_aa())
