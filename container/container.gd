extends Node3D

@onready var rb = $'RigidBody3D'

var fallen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rb.global_position.y <= 0:
		print("container ded")
		queue_free()
	
func on_velocity_update(velocity: Vector3):
	if not fallen:
		rb.linear_velocity.x = velocity.x
		rb.linear_velocity.z = velocity.z
