extends BossAction
class_name ManyRingsWavesAction

# Пишу тупую хрень, надо будет полностью переделать
var wave2 = true
var wave3 = true

func update(delta: float) -> void:
	if timer == 0:
		boss.wave.emit_wave(RingWave.new(
			boss.global_position,
			1000.0,  # максимальный радиус
			Color(0.3, 0.7, 1.0, 0.6),
			3.0,     # длительность
			30,
			40
		))
	
	if 1.3 <= timer and timer <= 3.0 and wave2:
		wave2 = false
		boss.wave.emit_wave(RingWave.new(
			boss.global_position,
			1000.0,  # максимальный радиус
			Color(0.3, 0.7, 1.0, 0.6),
			3.0,     # длительность
			30,
			40
		))
		
	if 3.0 <= timer and timer <= 5.0 and wave3:
		wave3 = false
		boss.wave.emit_wave(RingWave.new(
			boss.global_position,
			1000.0,  # максимальный радиус
			Color(0.3, 0.7, 1.0, 0.6),
			3.0,     # длительность
			30,
			80
		))
	
	timer += delta
	
	if timer >= 5.0:
		finished = true
