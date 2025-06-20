extends RefCounted
class_name Phase

var boss
var is_active: bool = false

func start(boss_ref):
	boss = boss_ref
	is_active = true

func update(delta):
	pass

func end():
	is_active = false
