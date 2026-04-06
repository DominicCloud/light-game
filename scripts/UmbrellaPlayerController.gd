extends Node3D

signal shade_state_changed(is_open: bool)

const GRAVITY: float = -9.8

@export var boost_strength: float = 22.0
@export var min_vertical_boost: float = 7.0
@export var boost_cooldown: float = 0.35
@export var reopen_delay: float = 0.45
@export var open_gravity_scale: float = 0.32
@export var closed_gravity_scale: float = 1.0
@export var terminal_velocity: float = 32.0
@export var max_horizontal_speed: float = 32.0
@export var look_sensitivity: float = 0.0038
@export var min_pitch_deg: float = -18.0
@export var max_pitch_deg: float = 60.0
@export var camera_distance: float = 7.0
@export var camera_height: float = 2.8
@export var camera_smooth: float = 6.5

var velocity: Vector3 = Vector3.ZERO
var is_open: bool = true

var _reopen_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _yaw: float = 0.0
var _pitch: float = 0.0
var _aim_direction: Vector3 = Vector3.FORWARD

@onready var _camera: Camera3D = $Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_yaw = rotation.y
	_pitch = deg_to_rad(20.0)
	_aim_direction = _get_aim_direction()

	var initial_camera_pos: Vector3 = global_position - _aim_direction * camera_distance + Vector3.UP * camera_height
	_camera.global_position = initial_camera_pos
	_camera.look_at(global_position + Vector3.UP * (camera_height * 0.35), Vector3.UP)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_yaw -= event.relative.x * look_sensitivity
		_pitch = clamp(
			_pitch - event.relative.y * look_sensitivity,
			deg_to_rad(min_pitch_deg),
			deg_to_rad(max_pitch_deg)
		)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	_cooldown_timer = max(0.0, _cooldown_timer - delta)

	if _reopen_timer > 0.0:
		_reopen_timer = max(0.0, _reopen_timer - delta)
		if _reopen_timer == 0.0:
			_set_open_state(true)

	_aim_direction = _get_aim_direction()

	if Input.is_action_just_pressed("ui_accept") and _cooldown_timer <= 0.0:
		_boost()

	var gravity_scale: float = open_gravity_scale if is_open else closed_gravity_scale
	velocity.y += GRAVITY * gravity_scale * delta

	if velocity.y < -terminal_velocity:
		velocity.y = -terminal_velocity

	var horizontal: Vector2 = Vector2(velocity.x, velocity.z)
	if horizontal.length() > max_horizontal_speed:
		horizontal = horizontal.normalized() * max_horizontal_speed
		velocity.x = horizontal.x
		velocity.z = horizontal.y

	global_position += velocity * delta
	look_at(global_position + _aim_direction, Vector3.UP)

func _process(delta: float) -> void:
	_update_camera(delta)

func _boost() -> void:
	_cooldown_timer = boost_cooldown
	_reopen_timer = reopen_delay
	_set_open_state(false)

	var boost_velocity: Vector3 = _aim_direction * boost_strength
	boost_velocity.y = max(boost_velocity.y, min_vertical_boost)
	velocity = boost_velocity

func _set_open_state(value: bool) -> void:
	if is_open == value:
		return
	is_open = value
	emit_signal("shade_state_changed", is_open)

func _get_aim_direction() -> Vector3:
	var cos_pitch: float = cos(_pitch)
	var sin_pitch: float = sin(_pitch)
	var cos_yaw: float = cos(_yaw)
	var sin_yaw: float = sin(_yaw)

	var direction: Vector3 = Vector3(
		sin_yaw * cos_pitch,
		sin_pitch,
		-cos_yaw * cos_pitch
	)

	return direction.normalized()

func _update_camera(delta: float) -> void:
	if not _camera:
		return

	var target_position: Vector3 = global_position - _aim_direction * camera_distance + Vector3.UP * camera_height
	var blend: float = clamp(camera_smooth * delta, 0.0, 1.0)

	_camera.global_position = _camera.global_position.lerp(target_position, blend)
	_camera.look_at(global_position + Vector3.UP * (camera_height * 0.35), Vector3.UP)
