extends KinematicBody2D

const MOVE_SPEED = 100

var move_dir = Vector2(-1, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if move_and_collide(move_dir * MOVE_SPEED * delta):
		move_dir *= -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
