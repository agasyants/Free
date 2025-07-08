extends BossAction
class_name CircleWaveAttackAction

func update(delta: float) -> void:
	if timer == 0:
		boss.wave.emit_wave(CircleWave.new(
			boss.global_position,
			300.0,
			Color(1, 0, 0, 0.4),
			1.0,       # duration
			30
		))
		
	timer += delta
	
	if timer >= 1.0:
		finished = true
