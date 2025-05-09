extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	set_collision_mask_value(2, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	body.canFall = true

func _on_body_exited(body):
	body.canFall = false
