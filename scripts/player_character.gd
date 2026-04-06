extends CharacterBody3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
var mesh_material: Material


# Movement
@export var move_speed: float = 10.0
@export var acceleration: float = 30.0

# Vertical motion
@export var gravity_strength: float = 25.0
@export var boost_speed: float = 12.0

# Tilt (visual only)
@export var tilt_speed: float = 8.0
@export var max_tilt: float = deg_to_rad(15.0)

func _ready() -> void:
	mesh_material = mesh_instance_3d.get_active_material(0)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		if Input.is_action_pressed("drop"):
			mesh_material.albedo_color = Color.RED
			velocity.y -= gravity_strength * 1.5 * delta
		elif Input.is_action_just_released("drop"):
			mesh_material.albedo_color = Color.GREEN
			velocity = Vector3(0, 5, 0)
		else:
			#if velocity.y < 0:
				#mesh_material.albedo_color = Color.GREEN
			mesh_material.albedo_color = Color.CYAN
			velocity.y -= gravity_strength/4 * delta
	else:
		velocity.y = 0.0

	# Boost (Space)
	if Input.is_action_just_pressed("boost"):
		velocity.y = boost_speed


	# Input (WASD)
	var input_dir := Vector3.ZERO

	if Input.is_action_pressed("forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("backward"):
		input_dir.z += 1
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()


	# Movement (snappy)
	var target_velocity = input_dir * move_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	# Tilt (visual feedback)
	var target_roll := -input_dir.x * max_tilt
	var target_pitch := input_dir.z * max_tilt

	rotation.z = lerp_angle(rotation.z, target_roll, tilt_speed * delta)
	rotation.x = lerp_angle(rotation.x, target_pitch, tilt_speed * delta)
	

	move_and_slide()
