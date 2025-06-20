extends Area2D

@export var speed := 800.0
@export var damage := 20
var direction := Vector2.RIGHT

func _ready():
	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage") and body.is_in_group('player'):
		body.take_damage(damage)
		queue_free()
