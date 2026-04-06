extends PathFollow3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	create_tween().tween_property(self, "progress_ratio", 1, 60)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
