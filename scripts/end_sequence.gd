extends PathFollow3D

@export var end_camera: Camera3D
@export var umbrella: CharacterBody3D
@export var kid: Kid
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@export var ui: Control
var is_playing_sequence := false


func play_cinematic() -> void:
	if is_playing_sequence:
		return
	is_playing_sequence = true

	# 1. Fade to black first
	await Fade.fade_out().finished
	
	# 2. Prepare scene while screen is black
	if kid:
		kid.sunburn_rate = 0.0
	if umbrella:
		umbrella.queue_free()
	
	# 3. Start the sequence (WAIT for it)
	await play_sequence()


func play_sequence() -> void:
	# 4. Start animation while still black
	animation_player.play("sq1")

	# 5. Fade in to reveal the cutscene already in progress
	await Fade.fade_in().finished

	# 6. Wait for animation to finish
	await animation_player.animation_finished
	
	# 6. Fade out again at the end (important for clean exit)
	Fade.crossfade_prepare(2.0)
	Fade.crossfade_execute()
	#await Fade.fade_in().finished
	# 7. Display credits (fade in -> linger -> fade out)
	await ui.display_credits()

	# 8. Quit
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
