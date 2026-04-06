extends PathFollow3D

signal level_complete
signal level_successful

@export var kid: Kid
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_complete.connect(_on_level_complete)
	
	await get_tree().create_timer(2.0).timeout
	create_tween().tween_property(self, "progress_ratio", 1, 60)
	var animation: AnimationPlayer = kid.get_node("AnimationPlayer")
	animation.play("mixamo_com")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if progress_ratio == 1.0:
		level_complete.emit()

func _on_level_complete() -> void:
	var animation: AnimationPlayer = kid.get_node("AnimationPlayer")
	if kid.health > 0.0:
		level_successful.emit()
	animation.stop()
