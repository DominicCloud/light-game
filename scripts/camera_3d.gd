extends Camera3D

@export var player: CharacterBody3D
@export var offset: Vector3 = Vector3(0, 2, 5)
@export var follow_speed: float = 5.0

@export var mouse_sensitivity: float = 0.002
@export var pitch_limit: float = deg_to_rad(80)

var yaw: float = 0.0
var pitch: float = 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -pitch_limit, pitch_limit)

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta: float) -> void:
	if not player:
		return

	# Create rotation basis from mouse
	var rotation_basis = Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, pitch)

	# Rotate offset around player
	var rotated_offset = rotation_basis * offset

	var target_position = player.global_position + rotated_offset

	# Smooth follow
	global_position = global_position.lerp(target_position, follow_speed * delta)

	# Look at player
	look_at(player.global_position, Vector3.UP)
