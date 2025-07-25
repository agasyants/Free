extends Control
class_name BossPhaseUI

@onready var phase_container: HBoxContainer = $PhaseContainer
var boss: Boss = null

func _ready():
	#add_to_group("boss_phase_ui")
	find_boss()

func find_boss():
	boss = get_tree().get_first_node_in_group("enemies") as Boss
	if boss:
		set_total_phases(boss.phases.size())
		set_current_phase(boss.current_phase_index)

func _process(_delta):
	if boss:
		set_current_phase(boss.current_phase_index)

func set_total_phases(count: int):
	for i in range(count):
		var icon = ColorRect.new()
		icon.color = Color.WHITE
		icon.custom_minimum_size = Vector2(16, 16)
		phase_container.add_child(icon)

func set_current_phase(index: int):
	for i in range(phase_container.get_child_count()):
		var icon = phase_container.get_child(i) as ColorRect

		if i < index-1:
			icon.color = Color.BLACK  # пройденные
		elif i > index:
			icon.color = Color.WHITE  # ещё не дошли
		else:
			icon.color = Color.WHITE
