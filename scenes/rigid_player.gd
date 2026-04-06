extends RigidBody3D

@export_range(750.0, 2500.0) var thrust: float = 800.0
@export var torque_thrust: float = 80.0

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)

	if Input.is_action_pressed("left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))

	if Input.is_action_pressed("right"):
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * delta))

	if Input.is_action_pressed("forward"):
		apply_central_force(-basis.z * delta * thrust)

	if Input.is_action_pressed("backward"):
		apply_central_force(basis.z * delta * thrust)
