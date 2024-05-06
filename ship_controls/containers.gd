extends Node3D

@onready var containers_left: int = self.get_child_count()

signal on_container_overboard(containers_left: int)

func _ready():
	on_container_overboard.emit(containers_left)

# Called when the node enters the scene tree for the first time.
func _process(delta):
	var new_containers_left: int = self.get_child_count()
	if new_containers_left < containers_left:
		containers_left = new_containers_left
		on_container_overboard.emit(containers_left)
	

func on_velocity_update(velocity: Vector3):
	for child in self.get_children():
		child.on_velocity_update(velocity)


