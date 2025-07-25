extends Node2D
class_name BulletManager

var bullets: Array[BulletData] = []
var logic_registry: Dictionary = {}    # logic_id -> BulletLogic (shared)
var renderer_registry: Dictionary = {} # renderer_id -> BulletRenderer (shared)

# Пул прокси для переиспользования
var proxy_pool: Array[BulletCollisionProxy] = []
var active_proxies: Array[BulletCollisionProxy] = []

@onready var camera: Camera = get_viewport().get_camera_2d()

func _ready():
	logic_registry = {
		"default": BulletLogic.new(),
		"homing": HomingBulletLogic.new()
	}
	
	renderer_registry = {
		"default": BulletRenderer.new(),
		"red": RedBulletRenderer.new(),
		"homing": HomingBulletRenderer.new()
	}
	
	# Предварительно создаем несколько прокси для пула
	_prewarm_proxy_pool(20)

func _prewarm_proxy_pool(count: int) -> void:
	for i in range(count):
		var proxy := preload("res://bullet/BulletCollisionProxy.tscn").instantiate()
		proxy.manager = self
		proxy.deactivate()  # Отключаем сразу
		add_child(proxy)
		proxy_pool.append(proxy)

func _process(delta: float) -> void:
	#print(proxy_pool.size(), " ", active_proxies.size())
	# Обновление всех пуль
	for bullet in bullets:
		bullet.logic.update(bullet, delta)
		bullet.renderer.update(bullet, delta)
	
	# Удаление мёртвых пуль и возврат их прокси в пул
	for i in range(bullets.size() - 1, -1, -1):
		var bullet := bullets[i]
		if bullet_should_die(bullet):
			_return_proxy_to_pool(bullet)
			bullets.remove_at(i)
	
	queue_redraw() # триггерим _draw

func _draw() -> void:
	for bullet in bullets:
		if camera and camera.is_visible_in_camera(bullet.position, bullet.radius):
			bullet.renderer.draw_canvas(self, bullet)

func bullet_should_die(b: BulletData) -> bool:
	return b.health <= 0 or b.lifetime <= 0

func _get_proxy_from_pool() -> BulletCollisionProxy:
	if proxy_pool.size() > 0:
		var proxy = proxy_pool.pop_back()
		active_proxies.append(proxy)
		return proxy
	else:
		# Если пул пуст, создаем новый прокси
		var proxy := preload("res://bullet/BulletCollisionProxy.tscn").instantiate()
		proxy.manager = self
		add_child(proxy)
		active_proxies.append(proxy)
		return proxy

func _return_proxy_to_pool(bullet: BulletData) -> void:
	# Ищем прокси этой пули среди активных
	for i in range(active_proxies.size() - 1, -1, -1):
		var proxy = active_proxies[i]
		if proxy.bullet_data == bullet:
			proxy.deactivate()  # Отключаем прокси
			active_proxies.remove_at(i)
			proxy_pool.append(proxy)  # Возвращаем в пул
			break

# Спавн новой пули
func spawn_bullet(config: Dictionary) -> void:
	var bullet := BulletData.new()
	bullet.position = config.get("position", Vector2.ZERO)
	bullet.velocity = config.get("velocity", Vector2.ZERO)
	bullet.speed = config.get("speed", 600.0)
	bullet.damage = config.get("damage", 5)
	bullet.radius = config.get("radius", 6.0)
	bullet.health = config.get("health", 1)
	bullet.lifetime = config.get("lifetime", 8.0)
	bullet.is_player = config.get("is_player", true)
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var players = get_tree().get_nodes_in_group("player")
	bullet.boss = enemies[0] if enemies.size() > 0 else null
	bullet.player = players[0] if players.size() > 0 else null
	
	var logic_id = config.get("logic_id", "default")
	var renderer_id = config.get("renderer_id", "default")
	
	if not logic_registry.has(logic_id):
		push_error("Unknown bullet logic ID: %s. Available: %s" % [logic_id, logic_registry.keys()])
		return
		
	if not renderer_registry.has(renderer_id):
		push_error("Unknown bullet renderer ID: %s. Available: %s" % [renderer_id, renderer_registry.keys()])
		return
	
	bullet.logic = logic_registry.get(logic_id)
	bullet.renderer = renderer_registry.get(renderer_id)
	
	# Получаем прокси из пула и настраиваем его
	var proxy = _get_proxy_from_pool()
	proxy.activate(bullet)
	proxy.global_position = bullet.position
	proxy.set_radius(bullet.radius)
	
	bullet.proxy = proxy
	bullets.append(bullet)

# Вызывать при столкновении с телом
func notify_body_entered(bullet: BulletData, body: Node) -> void:
	bullet.logic.on_body_entered(bullet, body)

# Вызывать при столкновении с другой пулей
func notify_bullet_entered(bullet: BulletData, other: BulletData) -> void:
	bullet.logic.on_bullet_entered(bullet, other)

# Вызывать при отскоке от стены
func notify_bullet_bounced(bullet: BulletData, wall_normal: Vector2) -> void:
	bullet.logic.on_bounce(bullet, wall_normal)

# Уничтожает все пули, возвращая их прокси в пул и очищая массив
func destroy_all_bullets() -> void:
	# Проходим по всем пулям в обратном порядке
	for i in range(bullets.size() - 1, -1, -1):
		var bullet := bullets[i]
		# Возвращаем прокси в пул
		_return_proxy_to_pool(bullet)
	# Полностью очищаем массив пуль
	bullets.clear()
