extends Area2D

@export var speed := 600.0
@export var damage := 10
var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2 = Vector2.ZERO

func _ready():
	connect("body_entered", _on_body_entered)

func setup(bullet_direction: Vector2, bullet_speed: float):
	direction = bullet_direction.normalized()
	speed = bullet_speed
	rotation = direction.angle()

func _physics_process(delta):
	velocity = direction * speed
	position += velocity * delta

	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage") and body.is_in_group('player'):
		body.take_damage(damage)
		queue_free()
