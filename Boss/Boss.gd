extends CharacterBody2D
class_name Boss

@onready var player = get_tree().get_first_node_in_group("player")
@onready var components = $Components
@onready var movement: BossMovementComponent = components.get_node("BossMovementComponent")
@onready var shoot: BossShootComponent = components.get_node("BossShootingComponent")
@onready var health: BossHealthComponent = components.get_node("BossHealthComponent")
@onready var laser: BossLaserComponent = components.get_node("BossLaserComponent")
@onready var wave: BossWaveComponent = components.get_node("BossWaveComponent")
@onready var bound: BoundaryComponent = components.get_node("BossBoundaryComponent")

signal boss_knocked

var phase: BossPhase
var current_phase_index := 0
var radius: float = 24

# Список фаз по порядку
var phases := [
	RandomPhase,
	SniperReactivePhase,
	AggressiveClosePhase,
	FinalPhase
]

func _ready():
	health.boss_died.connect(_on_boss_died)
	#_start_next_phase()

func _process(delta):
	wave.update(delta)
	if phase:
		phase.update(delta)
	bound.clamp_to_arena()
		
func take_damage(damage: int):
	health.take_damage(damage)

func set_phase(new_phase: BossPhase):
	phase = new_phase
	phase.boss = self
	phase.start()

func _on_boss_died():
	# Проверяем ДО увеличения индекса
	if current_phase_index >= phases.size():
		_die()
	else:
		_start_next_phase()

func _start_next_phase():
	laser.clear_lasers()
	if current_phase_index != 0:
		phase = null
		boss_knocked.emit()
		health.set_invulnerable(true)

		await get_tree().create_timer(0.6).timeout

		# Полное восстановление
		health.heal(health.max_health)
		health.set_invulnerable(false)
		
	var phase_class = phases[current_phase_index]
	current_phase_index += 1
	var new_phase = phase_class.new()
	set_phase(new_phase)

func _die():
	print("Boss is REALLY dead.")
	queue_free()

func wait_for_player_respawn():
	# ПЕРЕПИСАТЬ!!!
	phase = WaitForPlayerPhase.new()
	phase.boss = self
	await get_tree().process_frame
	laser.clear_lasers()
	
func restart_current_phase():
	var phase_class = phases[current_phase_index - 1]  # -1, т.к. уже увеличили
	var new_phase = phase_class.new()
	health.heal(health.max_health)
	set_phase(new_phase)
