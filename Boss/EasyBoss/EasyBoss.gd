extends Boss
class_name BossEasy

func _ready():
	phases = [
		EasyPhase1,
		EasyPhase2,
		RandomPhase
	]
	super._ready()
