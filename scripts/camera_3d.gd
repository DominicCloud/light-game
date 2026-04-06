extends Camera3D

@export var player: CharacterBody3D
@export var offset: Vector3 = Vector3(-5, 12, 12)
@export var follow_speed: float = 5.0

func _process(delta: float) -> void:
	if not player:
		return

	# Target position behind the player
	var target_position = player.global_position + offset

	# Smooth follow
	global_position = global_position.lerp(target_position, follow_speed * delta)

	# Always look at the player
	look_at(player.global_position, Vector3.UP)
