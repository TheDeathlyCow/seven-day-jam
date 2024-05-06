extends Node3D

signal area_entered(area: Area3D)

func _area_entered(area):
	area_entered.emit(area)
