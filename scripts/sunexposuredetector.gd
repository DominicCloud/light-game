class_name Kid
extends Node3D


## SunExposureDetector.gd
## Attach this script to the Kid node.
## Detects whether the kid is shaded by the umbrella using a distance check.

# ── Inspector Settings ────────────────────────────────────────────────────────

@export_group("References")
## The Kid's Node3D. Assign in the inspector.
@export var kid: Node3D
## The umbrella (PlayerCharacter) node.
@export var umbrella: UmbrellaPlayerController

@export_group("Shadow Settings")
## Radius of the umbrella's shadow on the ground.
@export var shadow_radius: float = 3.0
## Soft edge width — distance over which shade fades to full exposure.
@export var shadow_falloff: float = 0.5

@export_group("Sunburn Settings")
## Maximum health the kid can have.
@export var max_health: float = 100.0
## Health lost per second when fully exposed to the sun.
@export var sunburn_rate: float = 10.0
## Health recovered per second when fully shaded.
@export var recovery_rate: float = 4.0
## If true, health can recover in shade. If false, only sunburn accumulates.
@export var allow_recovery: bool = true

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

# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	health = max_health
	if not kid:
		push_error("SunExposureDetector: 'kid' is not assigned!")
	if not umbrella:
		push_error("SunExposureDetector: 'umbrella' is not assigned!")

func _physics_process(delta: float) -> void:
	if not kid:
		return

	exposure = _calculate_exposure()
	_update_health(delta)
	_emit_transition_signals()

# ── Core Logic ────────────────────────────────────────────────────────────────

## Returns 0.0 (fully shaded) to 1.0 (fully exposed).
## Uses the umbrella's horizontal distance to the kid and its open state.
func _calculate_exposure() -> float:
	if not umbrella:
		return 1.0

	# Umbrella must be open and above the kid to cast shade.
	if not umbrella.is_open:
		return 1.0
	if umbrella.global_position.y < kid.global_position.y:
		return 1.0

	var flat_dist := Vector2(
		umbrella.global_position.x - kid.global_position.x,
		umbrella.global_position.z - kid.global_position.z
	).length()

	# Fully shaded inside the radius, smooth falloff at the edge.
	return smoothstep(shadow_radius - shadow_falloff, shadow_radius + shadow_falloff, flat_dist)


## Applies sunburn or recovery to the kid's health based on current exposure.
func _update_health(delta: float) -> void:
	if exposure > 0.0:
		health -= sunburn_rate * exposure * delta
	elif allow_recovery:
		health += recovery_rate * delta

	health = clampf(health, 0.0, max_health)
	if health <= 0.0:
		kid_got_sunburnt.emit()
		queue_free()


## Fires transition signals when the kid crosses between shaded/exposed states.
func _emit_transition_signals() -> void:
	var is_exposed := exposure > 0.0
	if is_exposed and not _was_exposed:
		sun_exposure_started.emit()
	elif not is_exposed and _was_exposed:
		sun_exposure_ended.emit()
	_was_exposed = is_exposed

# ── Public Helpers ────────────────────────────────────────────────────────────

## Returns true if the kid is receiving any direct sunlight at all.
func is_exposed() -> bool:
	return exposure > 0.0

## Returns true if the kid is fully shaded.
func is_fully_shaded() -> bool:
	return exposure == 0.0

## Returns the kid's health as a normalised 0–1 value (useful for UI).
func get_health_normalised() -> float:
	return health / max_health
