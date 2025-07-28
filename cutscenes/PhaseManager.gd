extends CanvasLayer

signal intro_finished

@onready var label_boss_name: Label = $BossName
@onready var label_countdown: Label = $Countdown
@onready var label_author: Label = $Author
@onready var label_phase: Label = $Phase

var boss_name: String = "RED"
var countdown_start := 3
var auto_start := true
var beat: float = 0.37974683544

@onready var player: Player = null
@onready var boss: Boss = null
@onready var camera: Camera = get_viewport().get_camera_2d()

func _ready():
	player = get_tree().get_nodes_in_group("player").front()
	player.health_component.player_knocked.connect(player_knocked)
	boss = get_tree().get_nodes_in_group("enemies").front()
	boss.boss_knocked.connect(boss_knocked)
	hide_all()
	if auto_start:
		player.set_active(false)
		start_intro()
	else:
		boss._start_next_phase()
		

func hide_all():
	label_boss_name.hide()
	label_countdown.hide()
	label_author.hide()
	label_phase.hide()

func start_intro():
	hide_all()
	show_and_hide(label_boss_name, 1)
	await get_tree().create_timer(beat*8).timeout
	show_and_hide(label_author, 2)
	await get_tree().create_timer(beat*4).timeout
	await play_countdown()

	label_countdown.hide()

	emit_signal("intro_finished")
	boss._start_next_phase()
	player.set_active(true)

func show_and_hide(label:Label, k:float):
	label.modulate.a = 1.0  # сразу видимый
	label.show()

	var tween := create_tween()
	tween.tween_interval(1.0/k)  # ждём 2 секунды
	tween.tween_property(label, "modulate:a", 0.0, 2.0/k)  # исчезает за 2 секунды
	tween.tween_callback(label.hide)  # полностью скрываем (опционально)

func play_countdown():
	label_countdown.show()

	for i in range(countdown_start, 0, -1):
		label_countdown.text = str(i)
		label_countdown.scale = Vector2.ONE

		var tween := create_tween()
		tween.tween_property(label_countdown, "scale", Vector2(1.5, 1.5), 0.1)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		await get_tree().create_timer(beat).timeout

# ПЕРЕПИСАТЬ!!!
func player_knocked():
	player.set_active(false)
	player.health_component.is_healing = true
	boss.wait_for_player_respawn()
	camera.offset_factor = 0.0
	await get_tree().create_timer(4.5).timeout
	player.set_active(true)
	camera.offset_factor = 0.4
	await get_tree().create_timer(0.5).timeout
	player.health_component.is_healing = false
	boss.restart_current_phase()
	
func boss_knocked():
	show_and_hide(label_phase, 4)
	player.health_component.add_extra_lives(1)
	player.health_component.set_health(100)
	get_node("/root/Node2D/CanvasLayer/PlayerLivesUI").set_current_lives()
