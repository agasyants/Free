extends CharacterBody2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var components = $Components
@onready var movement: BossMovementComponent = components.get_node("BossMovementComponent")
@onready var shooting: BossShootingComponent = components.get_node("BossShootingComponent")
@onready var health: BossHealthComponent = components.get_node("BossHealthComponent")

var current_phase: Phase

func _ready():
	#health.died.connect(_on_boss_died)
	current_phase = RandomAttackPhase.new()
	current_phase.start(self)

func _process(delta):
	if current_phase:
		current_phase.update(delta)

func switch_phase(new_phase: Phase):
	if current_phase:
		current_phase.end()
	current_phase = new_phase
	current_phase.start(self)
	
func take_damage(amount: int):
	health.take_damage(amount)

func _on_boss_died():
	print("Boss death logic here (e.g. stop AI)")
