extends Node3D

@export var player: CharacterBody3D

func _area_entered(area):
	player.area_entered(area)
