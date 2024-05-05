extends Node3D

const KNOTS_CONVERSION_RATIO = 1.94384

@onready var label: Label = $'CanvasLayer/Label'
@export var ship_body: CharacterBody3D

var speed_state: int = 0

func _process(_delta):
	var heading = rad_to_deg(global_rotation.y)
	var speed = ship_body.velocity.length() * KNOTS_CONVERSION_RATIO
	
	label.set_text("Speed: %.2f kts\nHeading: %.2f°N" % [speed, heading])

 
