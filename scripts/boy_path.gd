extends PathFollow3D


func _ready() -> void:
	var move = create_tween().tween_property(self, "progress_ratio", 1, 30)
