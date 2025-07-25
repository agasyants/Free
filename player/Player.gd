extends CharacterBody2D
class_name Player

var state: types.PlayerState = types.PlayerState.IDLE
var radius: float = 22
var is_active: bool = true

# Компоненты
@onready var components = $Components
@onready var movement_component: MovementComponent = components.get_node("MovementComponent")
@onready var dash_component: DashComponent = components.get_node("DashComponent")
@onready var shooting_component: ShootingComponent = components.get_node("ShootingComponent")
@onready var boundary_component: BoundaryComponent = components.get_node("BoundaryComponent")
@onready var parry_component: ParryComponent = components.get_node("ParryComponent")
@onready var attack_component: MeleeAttackComponent = components.get_node("MeleeAttackComponent")
@onready var animation_component: AnimationComponent = components.get_node("AnimationComponent")
@onready var health_component: HealthComponent = components.get_node("HealthComponent")
@onready var label = get_node("/root/Node2D/CanvasLayer/Label")
@onready var fps = get_node("/root/Node2D/CanvasLayer/FPS")

func _physics_process(delta):
	if is_active:
		# Обрабатываем все компоненты
		movement_component.handle(delta)
		shooting_component.handle(delta)
		dash_component.handle(delta)
		attack_component.handle(delta)
		parry_component.handle(delta)
		#print(state)
		label.text = types.PlayerStateNames[state]
		fps.text = str(Engine.get_frames_per_second())
		# Применяем движение
		move_and_slide()
		# Ограничиваем границами экрана
		#boundary_component.clamp_to_screen()
	animation_component.handle(delta)

# Публичные методы для взаимодействия компонентов
func get_current_velocity() -> Vector2:
	return velocity
	
func set_state(new_state: types.PlayerState) -> void:
	if state == new_state:
		return
	
	state = new_state
	animation_component.play(types.PlayerStateNames[state])
	#animation_component.play("DASH")

func set_velocity_override(new_velocity: Vector2) -> void:
	velocity = new_velocity
	
func take_damage(damage: int) -> void:
	if health_component.take_damage(damage):
		animation_component.set_damaged()

func can_move() -> bool:
	return not dash_component.is_dashing()

func get_movement_direction() -> Vector2:
	return movement_component.get_last_direction()

func set_active(a: bool):
	is_active = a
	if !a:
		set_state(Types.PlayerState.IDLE)
