extends Node

## SunExposureDetector.gd
## Attach this script to the Kid node (or any node with access to the kid).
## Detects whether the kid is shaded from the sun using raycasting.
## The sun is assumed to be directly overhead (straight down).

# ── Inspector Settings ────────────────────────────────────────────────────────

@export_group("References")
## The Kid's CharacterBody3D (or Node3D). Assign in the inspector.
@export var kid: Node3D

@export_group("Raycast Settings")
## How high above the kid to start the ray. Should clear all geometry above.
@export var ray_start_height: float = 50.0
## Collision mask layers that can BLOCK the sun (umbrella + environment).
## Set this to match your umbrella and environment physics layers.
@export_flags_3d_physics var umbrella_layer: int = 2
@export_flags_3d_physics var environment_layer: int = 1
@export_flags_3d_physics var canopy_layer: int = 8
## Extra sample points around the kid for partial shade detection.
## 0 = single centre ray only. Higher = more accurate but more expensive.
@export_range(0, 8) var sample_count: int = 4
## Radius around the kid's origin to spread the sample points.
@export var sample_radius: float = 0.3

@export_group("Sunburn Settings")
## Maximum health the kid can have.
@export var max_health: float = 100.0
## Health lost per second when fully exposed to the sun.
@export var sunburn_rate: float = 10.0
## Health recovered per second when fully shaded.
@export var recovery_rate: float = 4.0
## If true, health can recover in shade. If false, only sunburn accumulates.
@export var allow_recovery: bool = true

@export_group("Debug")
## Draw debug rays in the editor viewport (requires Debug Draw plugin or Godot 4.3+).
@export var debug_draw: bool = true

# ── Public State (read from other scripts) ───────────────────────────────────

## 0.0 = fully shaded, 1.0 = fully exposed to the sun.
var exposure: float = 0.0
## Current health of the kid (0–max_health).
var health: float = max_health

# ── Signals ──────────────────────────────────────────────────────────────────

## Emitted once when the kid moves from shade into sunlight.
signal sun_exposure_started
## Emitted once when the kid moves from sunlight into shade.
signal sun_exposure_ended
## Emitted when health reaches 0.
signal kid_got_sunburnt

# ── Private ──────────────────────────────────────────────────────────────────

var _was_exposed: bool = false
var _space_state: PhysicsDirectSpaceState3D

# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	health = max_health
	# Grab the physics space from the kid's world (or fall back to self).
	if kid:
		_space_state = kid.get_world_3d().direct_space_state
	else:
		push_error("SunExposureDetector: 'kid' is not assigned!")

func _physics_process(delta: float) -> void:
	if not kid:
		return

	exposure = _calculate_exposure()
	_update_health(delta)
	_emit_transition_signals()

# ── Core Logic ────────────────────────────────────────────────────────────────

## Returns a value between 0.0 (fully shaded) and 1.0 (fully exposed).
## Uses multiple sample points around the kid for partial-shade detection.
func _calculate_exposure() -> float:
	var sample_points := _get_sample_points()
	var exposed_count := 0

	for point in sample_points:
		if _is_point_exposed(point):
			exposed_count += 1

	return float(exposed_count) / float(sample_points.size())


## Casts a single ray straight down from above `point`.
## Returns true if nothing blocks the sun before reaching the point.
func _is_point_exposed(point: Vector3) -> bool:
	var ray_origin := Vector3(point.x, point.y + ray_start_height, point.z)
	var ray_target := point  # straight down to the sample point

	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	var all_blocking := umbrella_layer | environment_layer | canopy_layer
	query.collision_mask = all_blocking
	# Exclude the kid's own collider so it doesn't block its own rays.
	if kid is CollisionObject3D:
		query.exclude = [kid.get_rid()]

	var result := _space_state.intersect_ray(query)

	if debug_draw:
		_draw_debug_ray(ray_origin, ray_target, result.is_empty())

	# If nothing was hit, the sun ray reached the kid unobstructed.
	return result.is_empty()


## Builds the list of world-space points to sample around the kid.
func _get_sample_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	var origin := kid.global_position

	# Always include the centre point.
	points.append(origin)

	# Add evenly-spaced points in a ring around the kid.
	if sample_count > 0:
		var angle_step := TAU / float(sample_count)
		for i in sample_count:
			var angle := angle_step * i
			var offset := Vector3(cos(angle) * sample_radius, 0.0, sin(angle) * sample_radius)
			points.append(origin + offset)

	return points


## Applies sunburn or recovery to the kid's health based on current exposure.
func _update_health(delta: float) -> void:
	if exposure > 0.0:
		# Partial exposure scales the damage proportionally.
		health -= sunburn_rate * exposure * delta
	elif allow_recovery:
		health += recovery_rate * delta

	health = clampf(health, 0.0, max_health)

	if health <= 0.0:
		kid_got_sunburnt.emit()


## Fires transition signals when the kid crosses between shaded/exposed states.
func _emit_transition_signals() -> void:
	var is_exposed := exposure > 0.0
	if is_exposed and not _was_exposed:
		sun_exposure_started.emit()
	elif not is_exposed and _was_exposed:
		sun_exposure_ended.emit()
	_was_exposed = is_exposed

# ── Debug ─────────────────────────────────────────────────────────────────────

func _draw_debug_ray(origin: Vector3, target: Vector3, is_exposed: bool) -> void:
	# Uses DebugDraw3D plugin if available, otherwise prints to output.
	# Replace with your preferred debug visualisation method.
	var color := Color.RED if is_exposed else Color.GREEN
	if Engine.has_singleton("DebugDraw3D"):
		Engine.get_singleton("DebugDraw3D").draw_line(origin, target, color)

# ── Public Helpers ────────────────────────────────────────────────────────────

## Returns true if the kid is receiving any direct sunlight at all.
func is_exposed() -> bool:
	return exposure > 0.0

## Returns true if the kid is fully shaded (no sample points are exposed).
func is_fully_shaded() -> bool:
	return exposure == 0.0

## Returns the kid's health as a normalised 0–1 value (useful for UI).
func get_health_normalised() -> float:
	return health / max_health
