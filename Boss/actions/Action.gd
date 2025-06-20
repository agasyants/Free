extends Node
class_name BossAction

signal completed

var boss

func run(boss_ref) -> void:
	boss = boss_ref
	await execute()
	emit_signal("completed")

func execute():
	pass
