extends Area3D

@export var camera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	camera.player = null
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
