extends PlayerAnimation
class_name ChargingDashAnimation

var charge_time: float = 3.0
var charged: bool = false
var charged_flash_timer: float = 0.0

func reset():
	timer = 0.0
	charged_flash_timer = 0.0
	charge_time = 3.0
	charged = false

func update(delta: float) -> void:
	timer += delta

	if not charged and timer >= charge_time:
		charged = true
		charged_flash_timer = 0.2

	if charged_flash_timer > 0.0:
		charged_flash_timer -= delta

func draw(target: CanvasItem, opacity: float, damaged: bool) -> void:
	var base_radius: float = 20.0
	var fill_color: Color = Color(1, 1, 1, opacity) if damaged else Color(0, 0, 0, opacity)
	var stroke_color: Color = Color(0, 0, 0, opacity) if damaged else Color(1, 1, 1, opacity)

	# Основной круг и треугольник
	target.draw_circle(Vector2.ZERO, base_radius, fill_color, true, -1, Settings.is_aa())
	target.draw_circle(Vector2.ZERO, base_radius, stroke_color, false, 2.0, Settings.is_aa())

	var tri_size := 14.0
	var triangle := PackedVector2Array([
		Vector2(tri_size, 0),
		Vector2(-tri_size * 0.6, tri_size * 0.6),
		Vector2(-tri_size * 0.6, -tri_size * 0.6)
	])
	target.draw_polygon(triangle, [stroke_color])

	# Зарядка — вращающиеся дуги
	var charge_ratio: float = clamp(timer / charge_time, 0.0, 1.0)
	var arc_alpha: float = charge_ratio * opacity
	var arc_color := stroke_color
	arc_color.a = arc_alpha

	var arc_count := 3
	for i in arc_count:
		var radius := base_radius + 10.0 + i * 5.0
		var speed := (1.0 + i * 0.5)
		var angle_offset := timer * speed * TAU
		var arc_span := 0.5 + charge_ratio * 1.5  # от ~0.5 до 2.0 рад

		var start_angle := angle_offset + i * PI * 0.5
		var end_angle := start_angle + arc_span

		target.draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 32, arc_color, 1.5, Settings.is_aa())
	
	# Вспышка при полной зарядке
	if charged_flash_timer > 0.0:
		var strength := charged_flash_timer / 0.2
		var flash_color := Color(1, 1, 1, strength * opacity)
		var flash_radius := base_radius + 30.0 * (1.0 - strength)
		target.draw_circle(Vector2.ZERO, flash_radius, flash_color, true, -1, Settings.is_aa())
