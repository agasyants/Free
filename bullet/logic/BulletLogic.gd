class_name BulletLogic
extends RefCounted

func update(bullet: BulletData, delta: float) -> void:
	bullet.position += bullet.velocity * bullet.speed * delta
	bullet.lifetime -= delta
	if bullet.lifetime <= 0:
		bullet.health = 0

func on_body_entered(bullet: BulletData, body: Node) -> void:
	if body.is_in_group("player") and body.state == types.PlayerState.PARRY:
		on_parried(bullet)
		return

	if body.is_in_group("player") and body.state == types.PlayerState.DASH:
		# Invulnerable during dash — no effect
		return

	if bullet.is_player:
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(bullet.damage)
			bullet.health = 0
	else:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(bullet.damage)
			bullet.health = 0

func on_bullet_entered(bullet: BulletData, other: BulletData) -> void:
	if bullet.is_player != other.is_player:
		if other.health < bullet.health:
			other.health = 0
			bullet.health -= 1
		elif other.health > bullet.health:
			bullet.health = 0
		else:
			other.health = 0
			bullet.health = 0

func on_parried(bullet: BulletData) -> void:
	bullet.is_player = true
	bullet.proxy.change_owner()
	if bullet.boss != null:
		bullet.velocity = (bullet.boss.position - bullet.position).normalized()
	else:
		bullet.velocity = -bullet.velocity.normalized()
	bullet.speed *= 1.5

func on_bounce(bullet: BulletData, wall_normal: Vector2) -> void:
	bullet.velocity = bullet.velocity.bounce(wall_normal).normalized()
