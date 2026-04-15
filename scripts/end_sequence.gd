extends PathFollow3D

@export var end_camera: Camera3D
@export var umbrella: CharacterBody3D
@export var kid: Kid
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var is_playing_sequence := false

func play_sequence():
	if is_playing_sequence:
		return
	
	is_playing_sequence = true

	animation_player.play("sq1")
	await animation_player.animation_finished
	
	
	animation_player.play("sq2")
	await animation_player.animation_finished

	await get_tree().create_timer(1.0).timeout
	get_tree().quit()


func play_cinematic() -> void:
	#create_tween().tween_property(self, "progress_ratio", 1, 5.0).set_ease(Tween.EASE_IN_OUT)
	#end_camera.current = true
	#end_camera.player = null
	kid.sunburn_rate = 0.0
	if umbrella:
		umbrella.queue_free()
	play_sequence()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta: float) -> void:
	if progress_ratio + 0.1 >= 1.0:
		await get_tree().create_timer(1.0).timeout
		get_tree().quit()
