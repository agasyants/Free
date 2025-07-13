extends CharacterBody2D
class_name Player

var state: types.PlayerState = types.PlayerState.IDLE
var radius: float = 22

# Компоненты
@onready var components = $Components
@onready var movement_component: MovementComponent = components.get_node("MovementComponent")
@onready var dash_component: DashComponent = components.get_node("DashComponent")
@onready var shooting_component: ShootingComponent = components.get_node("ShootingComponent")
#@onready var boundary_component: BoundaryComponent = components.get_node("BoundaryComponent")
@onready var parry_component: ParryComponent = components.get_node("ParryComponent")
@onready var attack_component: MeleeAttackComponent = components.get_node("MeleeAttackComponent")
@onready var animation_component: AnimationComponent = components.get_node("AnimationComponent")
@onready var health_component: HealthComponent = components.get_node("HealthComponent")
@onready var label = get_node("/root/Node2D/CanvasLayer/Label")
func _physics_process(delta):
	# Обрабатываем все компоненты
	movement_component.handle(delta)
	shooting_component.handle(delta)
	dash_component.handle(delta)
	animation_component.handle_animation(delta)
	attack_component.handle(delta)
	parry_component.handle(delta)
	#print(state)
	label.text = types.PlayerStateNames[state]
	# Применяем движение
	move_and_slide()
	
	# Ограничиваем границами экрана
	#boundary_component.clamp_to_screen()

# Публичные методы для взаимодействия компонентов
func get_current_velocity() -> Vector2:
	return velocity

func set_velocity_override(new_velocity: Vector2) -> void:
	velocity = new_velocity
	
func take_damage(damage: int) -> void:
	health_component.take_damage(damage)

func can_move() -> bool:
	return not dash_component.is_dashing()

func get_movement_direction() -> Vector2:
	return movement_component.get_last_direction()
