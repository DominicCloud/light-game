extends Area3D

@export var wind_direction: Vector3 = Vector3(1, 0, 0)  # Editable in Inspector
@export var wind_strength: float = 40.0
@export var resistance: float = 0.85  # 0 = full stop, 1 = no resistance

var umbrella: UmbrellaPlayerController

func _ready() -> void:
	_setup_particles()

func _setup_particles() -> void:
	var particles: GPUParticles3D = get_node_or_null("WindParticles")
	if not particles:
		return

	var mat: ParticleProcessMaterial = particles.process_material

	# Match emission box to the collision shape extents
	var col: CollisionShape3D = get_node_or_null("CollisionShape3D")
	if col and col.shape is BoxShape3D:
		mat.emission_box_extents = (col.shape as BoxShape3D).size / 2.0
		particles.position = col.position

	# Align particle flow with wind direction
	mat.direction = wind_direction.normalized()

func _process(delta: float) -> void:
	if not umbrella:
		return
	
	# Push player in wind direction
	umbrella.velocity += wind_direction.normalized() * wind_strength * delta
	
	# Apply drag on the axis opposing wind (simulates resistance/friction from wind)
	var opposing_velocity = umbrella.velocity.dot(-wind_direction.normalized())
	if opposing_velocity > 0:
		umbrella.velocity += wind_direction.normalized() * opposing_velocity * (1.0 - resistance)

func _on_body_entered(body: UmbrellaPlayerController) -> void:
	print("umbrella in area")
	umbrella = body

func _on_body_exited(body: Node3D) -> void:
	umbrella = null
