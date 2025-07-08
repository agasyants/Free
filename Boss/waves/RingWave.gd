extends Wave
class_name RingWave

const RENDER_STEPS: int = 128
const GLOW_COLOR: Color = Color(0.8, 0.9, 1.0, 0.7)
const PARTICLE_COUNT: int = 32

var center: Vector2
var max_radius: float
var color: Color
var thickness: float

# Кэширование
var _cached_radii: Array
var _last_timer: float = -1.0
var _particle_phases: Array = []

func _init(
	_center: Vector2,
	_max_radius: float,
	_color: Color,
	_duration: float,
	_damage: int,
	_thickness: float
) -> void:
	super._init(_duration, _damage)
	center = _center
	max_radius = _max_radius
	color = _color
	thickness = _thickness
	
	# Инициализация фаз частиц
	for i in range(PARTICLE_COUNT):
		_particle_phases.append(randf() * TAU)

func get_radii() -> Array:
	if timer != _last_timer:
		var t = clamp(timer / duration, 0.0, 1.0)
		var outer = max_radius * t
		var inner = max(outer - thickness, 0.0)
		_cached_radii = [inner, outer]
		_last_timer = timer
	return _cached_radii

func render(canvas: CanvasItem) -> void:
	var r = get_radii()
	var inner = r[0]
	var outer = r[1]
	
	if outer <= 0:
		return
	
	var progress = clamp(timer / duration, 0.0, 1.0)
	
	# Пульсация волны
	var pulse = sin(timer * 15.0) * 0.1 + 1.0
	var pulse_thickness = thickness * pulse
	
	if inner > 0:
		canvas.draw_circle(center, inner, Color(0, 0, 0, 0))
	
	# Основное кольцо с пульсацией
	canvas.draw_arc(center, outer, 0, TAU, RENDER_STEPS, 
		Color(color.r, color.g, color.b, pulse * 0.8), pulse_thickness)
	
	# Свечение краев
	var glow_width = 3.0 * (1.0 - progress)
	canvas.draw_arc(center, outer, 0, TAU, RENDER_STEPS, 
		GLOW_COLOR, glow_width)
		
	if inner > 0:
		canvas.draw_arc(center, inner, 0, TAU, RENDER_STEPS, 
			GLOW_COLOR, glow_width)
	
	# Энергетические частицы
	for i in range(PARTICLE_COUNT):
		var angle = _particle_phases[i] + timer * 5.0
		var particle_pulse = sin(angle * 3.0) * 0.5 + 0.5
		var radius_offset = particle_pulse * 4.0
		var particle_radius = outer + radius_offset
		
		var pos = center + Vector2(cos(angle), sin(angle)) * particle_radius
		var size = 2.0 + particle_pulse * 3.0
		var alpha = 0.5 + particle_pulse * 0.5
		
		canvas.draw_circle(pos, size, Color(GLOW_COLOR.r, GLOW_COLOR.g, GLOW_COLOR.b, alpha))

func is_inside(point: Vector2, radius: float = 0.0) -> bool:
	var r = get_radii()
	if r[1] <= 0:
		return false
		
	var dist = center.distance_to(point)
	return dist + radius >= r[0] and dist - radius <= r[1]
