extends RigidBody2D

var casted : bool = false
var submerged : bool = false
var stuck : bool = false

const AIR_RESISTANCE = 7.0
const WATER_RESISTANCE = 90.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(_delta):
	if stuck && linear_velocity.x != 0:
		syncStuck()
	if casted && submerged:
		when_submerged()
	elif casted && !submerged:
		linear_velocity.x = move_toward(linear_velocity.x, 0, AIR_RESISTANCE)

func when_submerged():
	angular_velocity = move_toward(angular_velocity, 0.5, 1.5)
	linear_velocity.x = move_toward(linear_velocity.x, 0, WATER_RESISTANCE)
	linear_velocity.y = move_toward(linear_velocity.y, 25, WATER_RESISTANCE)

func when_stuck():
	stuck = true

@rpc("any_peer", "call_local")
func syncStuck() -> void:
	linear_velocity.x = 0
	linear_velocity.y = 0
	angular_velocity = 0
	gravity_scale = 0
