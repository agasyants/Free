extends Area2D
class_name Bullet

@export var speed: float = 600.0
@export var damage: int = 5
@export var health: int = 1
@export var is_player: bool = true
@export var lifetime: float = 8.0
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("area_entered", _on_area_entered)

func _physics_process(delta: float) -> void:
	update_bullet(delta)
	position += velocity * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		die()

func update_bullet(_delta: float) -> void:
	# Override in subclasses if needed
	pass

func setup(bullet_direction: Vector2) -> void:
	velocity = bullet_direction.normalized()

func parry() -> void:
	is_player = true
	var boss = get_tree().get_nodes_in_group("enemies").front()
	if boss and boss is Node2D:
		velocity =  (boss.global_position - global_position).normalized()
		speed *= 1.5

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		var other := area as Bullet
		if other.is_player != is_player:
			if other.health < health:
				other.die()
				take_damage(1)
			elif other.health > health:
				take_damage(health)
			else:
				other.die()
				die()

# Парирование или получение урона
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.state == types.PlayerState.PARRY:
		parry()
		return
		
	if body.is_in_group("player") and body.state == types.PlayerState.DASH:
		return

	if is_player:
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(damage)
			die()
	else:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(damage)
			die()

func bounce_from_wall(normal: Vector2) -> void:
	velocity = velocity.bounce(normal).normalized()
