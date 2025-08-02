extends Node2D
class_name BossWaveComponent

var boss: Boss
var player: Player
var active_waves: Array[Wave] = []

func _ready():
	boss = get_parent().get_parent() as Boss
	player = get_tree().get_first_node_in_group("player")

func emit_wave(wave: Wave) -> void:
	active_waves.append(wave)

func clear_all_waves() -> void:
	active_waves.clear()

func update(delta: float) -> void:
	active_waves = active_waves.filter(func(w): return w.is_active())
	for wave in active_waves:
		wave.update(delta)
		if wave.is_inside(player.global_position, player.radius):
			player.take_damage(wave.damage, 1, 'wave', player.global_position - boss.global_position)
	queue_redraw()

func _draw() -> void:
	for wave in active_waves:
		wave.render(self)
