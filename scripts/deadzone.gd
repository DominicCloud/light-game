extends Area3D

@export var camera: Camera3D


func _ready():
	assert(camera != null, "Camera3D must be assigned in the Inspector!")


func _on_body_entered(body: Node3D) -> void:
	camera.player = null
	await get_tree().create_timer(1.0).timeout
	Fade.crossfade_prepare(1.0, "GradientHorizontal")
	get_tree().reload_current_scene()
	Fade.crossfade_execute()
