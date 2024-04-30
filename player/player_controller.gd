extends Node

@export var sensitivity: float = 0.005

@onready var camera = $"."

var rotation: Vector2 = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event):
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)


func rotate_camera(relative: Vector2):
	rotation.x += -relative.x * sensitivity
	rotation.y += -relative.y * sensitivity
	camera.transform.basis = Basis()
	camera.rotate_object_local(Vector3.UP, rotation.x)
	camera.rotate_object_local(Vector3.RIGHT, rotation.y)
