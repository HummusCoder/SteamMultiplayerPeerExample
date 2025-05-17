extends Node2D

@onready var line = $Line2D
@onready var hook = $Hook
@onready var fakeHook = $FakeHook

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var chargeTimer = 0
var spawnBuffer = 0.5
var fireAngle = Vector2.ZERO

var casting = false
var casted = false

const AIR_RESISTANCE = 7.0

# Called when the node enters the scene tree for the first time.
func _ready():
	hook.hide()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if spawnBuffer > 0:
		spawnBuffer -= delta
		return
	if Input.is_action_just_pressed("fire"):
		casting = true
		casted = false
		line.show()
		hook.hide()
	#if Input.is_action_pressed("fire"):
		#chargeTimer = clamp(chargeTimer + delta, 0, 1.6)
		#fireAngle = Vector2(-1000,0).rotated(line.get_angle_to(get_global_mouse_position()))
		#update_trajectory(fireAngle, chargeTimer, delta)
	if Input.is_action_just_released("fire") && casting:
		casting = false
		casted = true
		line.clear_points()
		line.hide()
		fakeHook.hide()
		hook.global_position.x = line.global_position.x
		hook.global_position.y = line.global_position.y
		hook.linear_velocity = Vector2.ZERO
		hook.apply_impulse(fireAngle * chargeTimer, Vector2.ZERO)
		hook.show()
		chargeTimer = 0

func _physics_process(delta):
	if casting:
		chargeTimer = clamp(chargeTimer + delta, 0, 1.6)
		fireAngle = Vector2(-300,0).rotated(line.get_angle_to(get_global_mouse_position()))
		update_trajectory(fireAngle, chargeTimer, delta)
	if casted:
		hook.linear_velocity.x = move_toward(hook.linear_velocity.x, 0, AIR_RESISTANCE)

func update_trajectory(dir: Vector2, timeCharged: float, delta: float):
	var max_points = 50
	line.clear_points()
	var pos: Vector2 = Vector2.ZERO
	var vel = dir * timeCharged
	for i in max_points:
		line.add_point(pos)
		vel.x = move_toward(vel.x, 0, AIR_RESISTANCE)
		vel.y += gravity * delta
		pos += vel * delta
		
