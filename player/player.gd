extends CharacterBody3D

@export var sensitivity: float = 0.005
@export var ship: CharacterBody3D
@export var water_mesh: MeshInstance3D
@export var water_ripple_vel_scale = 0.05
@export var still_water_ripple_scale = 0.025

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_VERTICAL_LOOK = PI / 2
const RIPPLE_PARAM_NAME = 'shader_param/ripple_time_scale'

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var accumulated_rotation: Vector2 = Vector2(0, 0)

var is_piloting = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if ship == null:
		push_error("Player root ship node cannot be null!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	
	var controlled_body = get_controlled_body()
	
	process_gravity(delta)
	process_shader_time_scale(controlled_body, delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		controlled_body.velocity.x = direction.x * SPEED
		controlled_body.velocity.z = direction.z * SPEED
	else:
		controlled_body.velocity.x = move_toward(velocity.x, 0, SPEED)
		controlled_body.velocity.z = move_toward(velocity.z, 0, SPEED)

	controlled_body.move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)
	if event.is_action_released('toggle_pilot_ship'):
		is_piloting = !is_piloting


func rotate_camera(relative: Vector2):
	accumulated_rotation.x += -relative.x * sensitivity
	accumulated_rotation.y += -relative.y * sensitivity
	accumulated_rotation.y = clamp(accumulated_rotation.y, -MAX_VERTICAL_LOOK, MAX_VERTICAL_LOOK)
	transform.basis = Basis()
	rotate_object_local(Vector3.UP, accumulated_rotation.x)
	rotate_object_local(Vector3.RIGHT, accumulated_rotation.y)


func process_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	#if not is_piloting and Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY


func get_controlled_body() -> CharacterBody3D:
	if is_piloting:
		return ship
	else:
		return self


func process_shader_time_scale(controlled_body: CharacterBody3D, delta):
	var time_scale = still_water_ripple_scale
	if is_piloting:
		var speed = controlled_body.velocity.length()
		speed *= water_ripple_vel_scale
		time_scale += speed
	
	var material = water_mesh.get_surface_override_material(0)
	material.set(RIPPLE_PARAM_NAME, time_scale)
		
