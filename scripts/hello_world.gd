extends Node


@export var text: String = ""
@export var meshLabel: TextMesh

# Called when the node enters the scene tree for the first time.
func _ready():
	meshLabel.text = text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
