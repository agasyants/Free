extends RefCounted
class_name BulletData

# --- Поведение ---
var position: Vector2
var velocity: Vector2
var speed: float
var damage: int
var radius: float
var health: int
var lifetime: float
var is_player: bool
var player: Player
var boss: Boss

var logic: BulletLogic
var renderer: BulletRenderer
var proxy: BulletCollisionProxy

# --- Визуальное состояние (для update + draw) ---
var time: float = 0.0
var trail: Array[Vector2] = []
const MAX_TRAIL_LENGTH := 8
