extends PathFollow3D

@export var end_camera: Camera3D
@export var umbrella: CharacterBody3D
@export var kid: Kid

func play_cinematic() -> void:
	create_tween().tween_property(self, "progress_ratio", 1, 3.0).set_ease(Tween.EASE_IN_OUT)
	end_camera.current = true
	kid.sunburn_rate = 0.0
	umbrella.process_mode = Node.PROCESS_MODE_DISABLED

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta: float) -> void:
	if progress_ratio + 0.1 >= 1.0:
		await get_tree().create_timer(1.0).timeout
		get_tree().quit()
