extends Node3D

@onready var body: CharacterBody3D = $'.'

@export var speed: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _physics_process(delta):
	body.velocity.z = speed
	body.move_and_slide()
