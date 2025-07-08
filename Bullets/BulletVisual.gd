extends Node2D

var time := 0.0
var trail := []
const MAX_TRAIL_LENGTH := 8

# Монохромные цвета с высокой контрастностью
var CORE_COLOR := Color.WHITE * 4.0
var OUTLINE_COLOR := Color(0.2, 0.2, 0.2, 0.9)
var FLASH_COLOR := Color.WHITE * 8.0
var TRAIL_COLOR := Color(0.8, 0.8, 0.8, 0.7)

var BASE_RADIUS := 6.0
var OUTLINE_RADIUS := 14.0
var SPARK_COUNT := 12  # Количество искр

func _ready():
	rotation = get_parent().rotation
	connect("visibility_changed", _on_visibility_changed)

func _on_visibility_changed():
	visible = is_visible_in_tree()

func _process(delta):
	time += delta
	queue_redraw()
	
	# Сохраняем позиции с интервалами для резкого трейла
	if Engine.get_frames_drawn() % 3 == 0:
		trail.insert(0, global_position)
		if trail.size() > MAX_TRAIL_LENGTH:
			trail.pop_back()

func _draw():
	if not visible:
		return
	var t = time
	
	# Агрессивный трейл из точек
	for i in range(trail.size()):
		var pos = to_local(trail[i])
		var size = BASE_RADIUS * 0.5 * (1.0 - float(i)/MAX_TRAIL_LENGTH)
		var alpha = 0.7 * (1.0 - pow(float(i)/MAX_TRAIL_LENGTH, 2))
		var color = Color.WHITE * (1.0 + 2.0 * (1.0 - float(i)/MAX_TRAIL_LENGTH))
		draw_circle(pos, size, color * alpha)
	
	# Контур с резкой пульсацией
	var pulse = abs(sin(t * 30.0)) * 3.0
	draw_arc(Vector2.ZERO, OUTLINE_RADIUS + pulse, 0, TAU, 16, 
			Color.WHITE, 1.5 + pulse * 0.2, true)
	
	# Ядро с хаотичной пульсацией
	var core_pulse = abs(sin(t * 40.0 + 1.0)) * 1.5 + abs(cos(t * 35.0)) * 1.2
	draw_circle(Vector2.ZERO, BASE_RADIUS + core_pulse, CORE_COLOR)
	
	# Искры (агрессивные выбросы)
	#var spark_angle = t * 20.0
	#for i in range(SPARK_COUNT):
		#var angle = spark_angle + i * TAU / SPARK_COUNT
		#var spark_length = (0.8 + sin(t * 10.0 + i) * 0.3) * OUTLINE_RADIUS
		#var end_point = Vector2(cos(angle), sin(angle)) * spark_length
		#var width = 1.0 + (sin(t * 15.0 + i) * 1.5)
		#draw_line(Vector2.ZERO, end_point, Color.WHITE, width, true)
	
	# Резкая вспышка при появлении
	if t < 0.15:  
		var flash_intensity = pow((0.15 - t) / 0.15, 0.5)
		draw_circle(Vector2.ZERO, 30 * flash_intensity, 
				  FLASH_COLOR * flash_intensity)
