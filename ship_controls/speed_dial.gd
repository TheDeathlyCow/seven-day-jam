extends Node3D

@export var indicator: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func cycle_state():
	indicator.rotate_object_local(Vector3.RIGHT, PI / 2)
	
	
