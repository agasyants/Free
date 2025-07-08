extends BossAction
class_name RingWaveAttackAction

var wave_emitted := false

func update(delta: float) -> void:
	timer += delta

	if not wave_emitted and timer >= 0.3:
		wave_emitted = true
		boss.wave.emit_wave(RingWave.new(
			boss.global_position,
			1000.0,  # максимальный радиус
			Color.RED,
			2.0,     # длительность
			30,
			40
		))

	if timer >= 2.0:
		finished = true
