extends CharacterBody2D

@onready var anim_player = $anim_player
@onready var sprite = $sprite

@export var health : float

const SPEED = 140.0
const AIRSPEED = 15.0
const JUMP_VELOCITY = -210.0
const FRICTION = 20.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facingLeft = false
var canFall = false
var momentum = 0
var airJumps = 1

#func _enter_tree():
	#set_multiplayer_authority(str(name).to_int())
	
	#camera.current = true

@rpc("any_peer", "call_local")
func set_authority(id : int) -> void:
	set_multiplayer_authority(id)

func _physics_process(delta):
	if is_multiplayer_authority():
		set_collision_mask_value(2, true)
		set_collision_mask_value(3, true)
		set_collision_mask_value(4, true)
		
		anim_player.play("idle")
		
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
			if Input.is_action_just_pressed("jump") and airJumps > 0:
					velocity.y = JUMP_VELOCITY
					airJumps -= airJumps
					if !Input.get_axis("left", "right"):
						velocity.x = 0
			if Input.is_action_pressed("down"):
					set_collision_mask_value(2, false)
					set_collision_mask_value(3, false)
					set_collision_mask_value(4, false)
			
			#if Input.is_action_pressed("jump"):
				#if Input.is_action_pressed("down"):
					#set_collision_mask_value(2, false)
					#set_collision_mask_value(3, false)
					#set_collision_mask_value(4, false)
				#elif Input.is_action_just_pressed("jump") and airJumps > 0:
					#velocity.y = JUMP_VELOCITY
					#airJumps -= airJumps
					#if !Input.get_axis("left", "right"):
						#velocity.x = 0
		
		#Handle jump
		#if Input.is_action_just_pressed("jump") and is_on_floor():
			#if Input.is_action_pressed("down") and canFall:
				#set_collision_mask_value(2, false)
				#set_collision_mask_value(3, false)
				#set_collision_mask_value(4, false)
			#else:
				#velocity.y = JUMP_VELOCITY
		if is_on_floor():
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY
			if Input.is_action_pressed("down"):
				set_collision_mask_value(2, false)
				set_collision_mask_value(3, false)
				set_collision_mask_value(4, false)
		
		#var input_direction = Input.get_vector("left", "right", "up", "down")
		var input_direction = Input.get_axis("left", "right")
		
		#if input_direction and controlling:
		if is_on_floor():
			if airJumps == 0:
				airJumps = 1
			if momentum != 0 && abs(momentum) > abs(SPEED):
				if velocity.x * input_direction < 0:
					momentum += input_direction * AIRSPEED
					velocity.x = momentum
				else:
					velocity.x = momentum
			else:
				velocity.x = input_direction * SPEED
			
			momentum = move_toward(momentum, 0, FRICTION)
			
			######################################
			#flips sprite when changing directions
			######################################
			if ((velocity.x < 0 && facingLeft == false) || (velocity.x > 0 && facingLeft == true)):
				sprite.scale.x *= -1
				facingLeft = !facingLeft
			
		if !is_on_floor():
			#momentum += input_direction * AIRSPEED * delta
			if abs(velocity.x) > abs(SPEED):
				if velocity.x * input_direction < 0:
					velocity.x += input_direction * AIRSPEED
			else:
				velocity.x += input_direction * AIRSPEED
				#velocity.x = input_direction * SPEED
			momentum = velocity.x
		move_and_slide()

func set_player_name(value : String):
	$label.text = value

@rpc("any_peer", "call_local")
func teleport(new_position : Vector2) -> void:
	self.position = new_position
