extends Node3D

const KNOTS_CONVERSION_RATIO = 1.94384

@onready var label: Label = $'CanvasLayer/Label'
@export var ship_body: CharacterBody3D

var speed_state: int = 0

var heading: float = 0
var num_containers: int = 0

func _process(_delta):
	var heading_deg = rad_to_deg(heading)
	var speed = ship_body.velocity * KNOTS_CONVERSION_RATIO
	speed.y = 0
	label.set_text("Speed: %.2f kts\nRudder angle: %.2f°\nContainers Left: %d" % [speed.length(), heading_deg, num_containers])

func update_heading(new_heading: float):
	heading = new_heading
	
func update_containers_left(new_num_containers: int):
	num_containers = new_num_containers
