extends Control

@onready var hp_bar_front: TextureProgressBar
@onready var hp_bar_back: TextureProgressBar

var tween: Tween
var current_hp: float = 100.0
var max_hp: float = 100.0

func _ready():
	# Настройка баров
	setup_hp_bars()

func setup_hp_bars():
	hp_bar_front = get_node("FrontHealthBar")
	hp_bar_back = get_node("BackHealthBar")
	# Настройка значений
	hp_bar_front.max_value = max_hp
	hp_bar_back.max_value = max_hp
	hp_bar_front.value = current_hp
	hp_bar_back.value = current_hp
	
	# Настройка цветов и слоев
	hp_bar_front.modulate = Color.WHITE  # Зеленый для текущего HP
	hp_bar_back.modulate = Color.DIM_GRAY     # Красный для показа урона
	
	# Убеждаемся что задний бар позади переднего
	hp_bar_back.z_index = 0
	hp_bar_front.z_index = 1

# Эта функция вызывается извне (например, от босса)
func update_hp(new_hp: int, new_max_hp: int):
	if not hp_bar_back or not hp_bar_front:
		_ready()
	show()
	
	var old_hp = current_hp
	current_hp = float(new_hp)
	max_hp = float(new_max_hp)
	
	# Обновляем максимальные значения
	hp_bar_front.max_value = max_hp
	hp_bar_back.max_value = max_hp
	
	# Если HP уменьшился - анимируем урон
	if current_hp < old_hp:
		animate_damage(current_hp)
	# Если HP увеличился - мгновенно обновляем (лечение)
	else:
		hp_bar_front.value = current_hp
		hp_bar_back.value = current_hp

func animate_damage(to_hp: float):
	# Останавливаем предыдущую анимацию
	if tween and tween.is_valid():
		tween.kill()
	
	# Сразу показываем новое значение на переднем баре
	hp_bar_front.value = to_hp
	
	# Задний бар остается на старом значении и плавно уменьшается
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	
	# Небольшая пауза перед анимацией
	tween.tween_interval(0.3)
	
	# Плавно уменьшаем задний бар
	tween.tween_property(hp_bar_back, "value", to_hp, 0.8)
