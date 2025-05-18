extends Node2D

@onready var trajectoryLine = $TrajectoryLine
@onready var line = $Line
@onready var hook = $Hook
@onready var fakeHook = $FakeHook

var fisher : Node2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var chargeTimer = 0
var spawnBuffer = 1
var fireAngle = Vector2.ZERO

var casting = false
var casted = false

const AIR_RESISTANCE = 7.0

# Called when the node enters the scene tree for the first time.
func _ready():
	hook.hide()
	line.hide()
	if get_parent().get_parent():
		fisher = get_parent().get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("debug"):
			print("hook is at ", hook.global_position)
			print("lineEnd is at ", line.points[1])
		if spawnBuffer > 0:
			spawnBuffer -= delta
			return
		if Input.is_action_just_pressed("fire"):
			casting = true
			casted = false
			trajectoryLine.show()
			hook.hide()
		if Input.is_action_just_released("fire") && casting:
			casting = false
			casted = true
			trajectoryLine.clear_points()
			trajectoryLine.hide()
			fakeHook.hide()
			hook.global_position.x = trajectoryLine.global_position.x
			hook.global_position.y = trajectoryLine.global_position.y
			hook.linear_velocity = Vector2.ZERO
			if fisher != null && fisher.has_method("_is_facing_left"):
				if fisher._is_facing_left():
					fireAngle.x *= -1
			hook.apply_impulse(fireAngle * chargeTimer, Vector2.ZERO)
			hook.show()
			chargeTimer = 0

func _physics_process(delta):
	if is_multiplayer_authority():
		if casting:
			chargeTimer = clamp(chargeTimer + delta, 0, 1.6)
			fireAngle = Vector2(-300,0).rotated(trajectoryLine.get_angle_to(get_global_mouse_position()))
			update_trajectory(fireAngle, chargeTimer, delta)
		if casted:
			line.show()
			update_line()
			hook.linear_velocity.x = move_toward(hook.linear_velocity.x, 0, AIR_RESISTANCE)

func update_trajectory(dir: Vector2, timeCharged: float, delta: float):
	var max_points = 50
	trajectoryLine.clear_points()
	var pos: Vector2 = Vector2.ZERO
	var vel = dir * timeCharged
	for i in max_points:
		trajectoryLine.add_point(pos)
		vel.x = move_toward(vel.x, 0, AIR_RESISTANCE)
		vel.y += gravity * delta
		pos += vel * delta
		
func update_line():
	line.points[1].x = hook.position.x
	line.points[1].y = hook.position.y
