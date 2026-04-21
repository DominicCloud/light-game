class_name UmbrellaPlayerController
extends CharacterBody3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var _canopy: MeshInstance3D = $sprite/canopy
@onready var _anim: AnimationPlayer = $sprite/anim
@onready var umbrella_close_sfx: AudioStreamPlayer = $umbrella_close_sfx

var is_open: bool = true
@export var camera: Camera3D

## Speed at which the canopy opens/closes (0→1 range per second).
@export var canopy_speed: float = 4

# Movement
@export var move_speed: float = 5.0
@export var acceleration: float = 30.0

# Vertical motion
@export var gravity_strength: float = 25.0
@export var boost_speed: float = 5.0

# Tilt (visual only)
@export var tilt_speed: float = 8.0
@export var max_tilt: float = deg_to_rad(15.0)

var _canopy_value: float = 0.0

func _ready() -> void:
	if not camera:
		camera = get_tree().get_first_node_in_group("Camera") as Camera3D
	
	if not _canopy:
		push_error("UmbrellaPlayerController: could not find 'canopy' node under $sprite")
		return
	_anim.stop()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	# Determine target canopy state
	var canopy_target: float
	#if Input.is_action_just_pressed("drop"):
		## play audio
		#umbrella_close_sfx.play()
		
	if not is_on_floor() and Input.is_action_pressed("drop"):
		is_open = false
		# play audio
		umbrella_close_sfx.play()
		canopy_target = 1.0
		velocity.y -= gravity_strength * 1.5 * delta
	else:
		if Input.is_action_just_released("drop"):
			velocity = Vector3(0, 5, 0)
		is_open = true
		canopy_target = 0.0
		if is_on_floor():
			velocity.y = 0.0
		else:
			velocity.y -= gravity_strength / 4 * delta

	# Smooth blend shape transition from any intermediate value
	_canopy_value = move_toward(_canopy_value, canopy_target, canopy_speed * delta)
	if _canopy:
		_canopy.set_blend_shape_value(0, _canopy_value)

	# Boost (Space)
	if Input.is_action_just_pressed("boost"):
		is_open = true
		velocity.y = boost_speed

	# Input (WASD)
	var input_dir := Vector3.ZERO

	if Input.is_action_pressed("forward"):
		input_dir.z += 1
	if Input.is_action_pressed("backward"):
		input_dir.z -= 1
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	# Move relative to camera
	var move_dir := Vector3.ZERO
	if camera:
		var cam_forward := -camera.global_transform.basis.z
		var cam_right := camera.global_transform.basis.x

		cam_forward.y = 0.0
		cam_right.y = 0.0
		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()

		move_dir = (cam_right * input_dir.x + cam_forward * input_dir.z).normalized()
	else:
		move_dir = input_dir

	# Movement
	var target_velocity := move_dir * move_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	# Tilt (visual feedback)
	var target_roll := -move_dir.x * max_tilt
	var target_pitch := move_dir.z * max_tilt

	rotation.z = lerp_angle(rotation.z, target_roll, tilt_speed * delta)
	rotation.x = lerp_angle(rotation.x, target_pitch, tilt_speed * delta)

	move_and_slide()
