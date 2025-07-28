extends Node
class_name MeleeAttackComponent

var combo_attacks: Array[RefCounted] = [
		#LightSlash1.new(),
		#LightSlash2.new(),
		#LightSlash3.new()
	]
var charged_attack: RefCounted #= ChargedSlash.new()
@export var charge_threshold := 0.6
@export var combo_window := 0.4

@onready var body: CharacterBody2D = get_parent().get_parent()
@onready var movement: MovementComponent = body.get_node("Components/MovementComponent")
@onready var animation: AnimationComponent = body.get_node("Components/AnimationComponent")

var current_attack: MeleeAttack = null
var combo_index := 0
var combo_timer := 0.0
var is_charging := false
var charge_time := 0.0

func handle(delta):
	if current_attack:
		current_attack.update(self, delta)
		if current_attack.finished:
			current_attack = null
	else:
		if Input.is_action_just_pressed("attack"):
			is_charging = true
			charge_time = 0.0
		elif Input.is_action_pressed("attack") and is_charging:
			charge_time += delta
		elif Input.is_action_just_released("attack"):
			if charge_time >= charge_threshold:
				_start_attack(charged_attack)
			else:
				_start_attack(combo_attacks[combo_index])
				combo_index += 1
				combo_timer = combo_window
			is_charging = false

	if combo_timer > 0:
		combo_timer -= delta
	else:
		combo_index = 0

func _start_attack(attack: MeleeAttack):
	current_attack = attack.duplicate()
	current_attack.start(self)

func get_attack_direction() -> Vector2:
	var target = _find_closest_enemy_in_front()
	if target:
		return (target.global_position - body.global_position).normalized()
	return movement.get_last_direction()

func _find_closest_enemy_in_front() -> Node2D:
	# Временно — сделай более сложную фильтрацию позже
	#var area := Rect2(body.global_position + movement.get_last_direction() * 100, Vector2(50, 50))
	for node in get_tree().get_nodes_in_group("enemies"):
		if node.global_position.distance_to(body.global_position) < 150:
			return node
	return null

func apply_damage(shape: Shape2D, transform: Transform2D, damage: int):
	const BOSS_LAYER := 2

	var space_state = body.get_world_2d().direct_space_state

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = transform
	query.collision_mask = 1 << BOSS_LAYER
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var hits = space_state.intersect_shape(query)

	for result in hits:
		var collider: Object = result.get("collider")
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)
