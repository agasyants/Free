extends CharacterBody2D
class_name Boss

@onready var player = get_tree().get_first_node_in_group("player")
@onready var components = $Components
@onready var movement: BossMovementComponent = components.get_node("BossMovementComponent")
@onready var shoot: BossShootComponent = components.get_node("BossShootingComponent")
@onready var health: BossHealthComponent = components.get_node("BossHealthComponent")
@onready var laser: BossLaserComponent = components.get_node("BossLaserComponent")
@onready var wave: BossWaveComponent = components.get_node("BossWaveComponent")

var phase: BossPhase
var current_phase_index := 0

# Список фаз по порядку
var phases := [
	RandomPhase,
	AggressiveClosePhase,
	SniperReactivePhase
]

func _ready():
	health.boss_died.connect(_on_boss_died)
	_start_next_phase()

func _process(delta):
	wave.update(delta)
	if phase:
		phase.update(delta)
		
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
	var phase_class = phases[current_phase_index]
	current_phase_index += 1

	print("Switching to phase %d: %s" % [current_phase_index, phase_class])

	# Небольшой переход с неуязвимостью
	health.set_invulnerable(true)

	await get_tree().create_timer(0.5).timeout

	var new_phase = phase_class.new()
	set_phase(new_phase)

	# Полное восстановление
	health.heal(health.max_health)
	health.set_invulnerable(false)

func _die():
	print("Boss is REALLY dead.")
	queue_free()
