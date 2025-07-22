extends RefCounted
class_name PlayerAnimation

signal animation_finished

var duration: float = 0.0
var timer: float = 0.0
var finished: bool = false

var player: Player  # Ссылка на игрока

# Масштаб изменения шума (чем меньше, тем плавнее)
@export var noise_scale: float = 100.0
# Переменная для шума
var noise: FastNoiseLite

func _init(player_ref: Player) -> void:
	timer = 0.0
	player = player_ref

func update(delta: float) -> void:
	timer += delta

	if not finished and duration > 0.0 and timer >= duration:
		finished = true
		emit_signal("animation_finished")

func draw(_target: CanvasItem, _opacity: float, _damaged: bool) -> void:
	# override in subclass
	pass

func reset() -> void:
	timer = 0.0
	finished = false

func _draw_ellipse(
	target: CanvasItem,
	center: Vector2,
	radius: float,
	x_scale: float,
	y_scale: float,
	color: Color,
	width: float = -1.0,
	segments: int = 32
) -> void:
	var points := PackedVector2Array()
	for i in segments:
		var angle := TAU * i / segments
		var x := cos(angle) * radius * x_scale
		var y := sin(angle) * radius * y_scale
		points.append(center + Vector2(x, y))
		
	if width > 0.0:
		target.draw_polyline(points, color, width, Settings.is_aa())
		target.draw_line(points[-1], points[0], color, width, Settings.is_aa())
	else:
		target.draw_polygon(points, [color])
	

func get_noise(i:int):
	if !noise:
		noise = FastNoiseLite.new()
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		noise.seed = randi() # Случайное зерно для уникальности
		noise.fractal_octaves = 2 # Плавность шума
		noise.frequency = 0.01 # Частота шума
		
	return (noise.get_noise_2d(float(i) * 200.0, timer * noise_scale * 2)) * 10

func generate_random_points_in_radius(radius: float, n: int):
	var points = []
	for i in range(n):
		var angle = randf() * 2 * PI
		var r = randf() * radius / 2 + radius / 2
		var x = r * cos(angle)
		var y = r * sin(angle)
		points.append(Vector2(x, y))
	return points
