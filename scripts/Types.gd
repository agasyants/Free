extends Node

class_name Types

enum PlayerState {
	IDLE,
	SHOOT,
	CHARGING_DASH,
	DASH,
	CHARGING_ATTACK,
	ATTACK,
	PARRY
}

const PlayerStateNames = {
	PlayerState.IDLE: "IDLE",
	PlayerState.SHOOT: "SHOOT",
	PlayerState.CHARGING_DASH: "CHARGING_DASH",
	PlayerState.DASH: "DASH",
	PlayerState.CHARGING_ATTACK: "CHARGING_ATTACK",
	PlayerState.ATTACK: "ATTACK",
	PlayerState.PARRY: "PARRY"
}

var state_speeds = {
	PlayerState.IDLE: 320.0,                          # Обычная скорость передвижения
	PlayerState.SHOOT: 180.0,                         # Замедлен во время стрельбы
	PlayerState.CHARGING_DASH: 50.0,                  # Сильно замедлен при зарядке рывка
	PlayerState.DASH: 400.0,                          # Очень быстрый во время рывка
	PlayerState.CHARGING_ATTACK: 50.0,                # Замедлен при зарядке атаки
	PlayerState.ATTACK: 50.0,                         # Немного замедлен во время атаки
	PlayerState.PARRY: 0.0                            # Не может двигаться во время парирования
}

var state_accelerations = {
	PlayerState.IDLE: 0.2,
	PlayerState.SHOOT: 0.1,
	PlayerState.CHARGING_DASH: 0.05,
	PlayerState.DASH: 0.2,
	PlayerState.CHARGING_ATTACK: 0.05,
	PlayerState.ATTACK: 0.02,
	PlayerState.PARRY: 0.0
}
