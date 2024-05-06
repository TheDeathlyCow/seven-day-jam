extends CharacterBody3D

@export var sensitivity: float = 0.005
@export var ship: CharacterBody3D
@export var water_mesh: MeshInstance3D
@export var water_ripple_vel_scale = 0.05
@export var still_water_ripple_scale = 0.025
@export var ship_rot_speed = 1e-2
@export var ship_wheel_rot_speed = 1e-2
@export var SPEED = 5.0
@export var steering_wheel: Node3D = null
@export var max_ship_speed = 3.0

const JUMP_VELOCITY = 4.5
const MAX_VERTICAL_LOOK = PI / 2
const RIPPLE_PARAM_NAME = 'ripple_time_scale'
const WAVE_TIME_PARAM_NAME = 'time'
const ACTIVATE_LENGTH = 2.0

signal toggle_ship_speed
signal update_ship_velocity(velocity: Vector3)
signal update_heading(heading: float)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var accumulated_rotation: Vector2 = Vector2(0, 0)
var accumulated_ship_rotate: float = 0
var is_piloting = false
var ship_speed: int = 0

var wave_time: float = 0

var ended: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if ship == null:
		push_error("Player root ship node cannot be null!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	
	if ended:
		return
	
	var controlled_body = get_controlled_body()
	
	process_gravity(delta)
	process_shader_time_scale(delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	
	if is_piloting:
		input_dir.y = 0
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var ship_velocity = ship.get_global_transform().basis.z * (ship_speed / 3.0) * max_ship_speed

		
	ship_velocity = ship_velocity.rotated(Vector3.UP, accumulated_ship_rotate)
	update_ship_velocity.emit(ship_velocity)
	self.velocity = ship_velocity
	ship.velocity = ship_velocity
	
	if is_piloting:
		
		var rotation = direction.x * ship_rot_speed * delta
		var next_accumulated_rotation = accumulated_ship_rotate + rotation
		
		if abs(next_accumulated_rotation) <= PI / 4 and ship.velocity.length_squared() > 0:
			accumulated_ship_rotate = next_accumulated_rotation
			update_heading.emit(accumulated_ship_rotate)
			#controlled_body.rotate_object_local(Vector3.UP, rotation)
			steering_wheel.rotate_object_local(Vector3.UP, direction.x * ship_wheel_rot_speed)
	else:
		if direction:		
			controlled_body.velocity.x += direction.x * SPEED
			controlled_body.velocity.z += direction.z * SPEED
		else:
			controlled_body.velocity.x += move_toward(velocity.x, 0, SPEED)
			controlled_body.velocity.z += move_toward(velocity.z, 0, SPEED)
		
	self.move_and_slide()	
	ship.move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)
	if event.is_action_released('activate'):
		if is_piloting:
			is_piloting = false
		else:
			activate()

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


func process_shader_time_scale(delta):
	wave_time += delta
	var time_scale = still_water_ripple_scale
	var material: ShaderMaterial = water_mesh.get_surface_override_material(0)
	material.set_shader_parameter(RIPPLE_PARAM_NAME, time_scale)
	material.set_shader_parameter(WAVE_TIME_PARAM_NAME, wave_time)
		

func activate():
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * ACTIVATE_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)

	if not result.has('collider'):
		return
	var collider = result['collider']
	if collider != null and collider is Area3D:
		var area = collider as Area3D
		var groups = area.get_groups()
		if groups.has("steering_wheel"):
			print("piloting")
			is_piloting = true
		elif groups.has("speed_dial"):
			print("toggle speed")
			ship_speed += 1
			ship_speed %= 4
			toggle_ship_speed.emit()
			

func process_wave_height(delta):
	var wave_height = 75
	var wave1_scale = 0.032
	var wave2_scale = 0.044
	var wave_time_scale = 0.2
	var world_pos = ship.global_position
	
	var height1 = wave_height * sin(world_pos.x * wave1_scale + wave_time * wave_time_scale);
	#var height2 = wave_height * cos(world_pos.z * wave2_scale + wave_time * wave_time_scale + PI/2.0);
	
	var height = height1 
	
	if height > ship.global_position.y - 10:
		ship.global_position.y = height - 5
		self.global_position.y = height - 5
		print('push up')
	else:
		ship.velocity.y -= gravity * delta
		print('push down')

func area_entered(area: Area3D):
	if area.get_groups().has('end'):
		ended = true
		print('END')
	
