extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_body_entered(body):
	if body.has_method("when_stuck"):
		body.when_stuck()

func _on_body_exited(body):
	if body.has_method("when_stuck"):
		body.stuck = false
