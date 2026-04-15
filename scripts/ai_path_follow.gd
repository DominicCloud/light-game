extends PathFollow3D

signal level_complete
signal play_wind_audio
signal level_successful
@onready var wind_sfx: AudioStreamPlayer = $wind

@export var camera: Camera3D
@export var kid: Kid
@export var end_sequnce: PathFollow3D

@export_category("Level Parameters")
@export_range(2,60) var length_in_time: int = 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_complete.connect(_on_level_complete)
	play_wind_audio.connect(_play_audio)
	
	await get_tree().create_timer(2.0).timeout
	create_tween().tween_property(self, "progress_ratio", 1, length_in_time)
	var animation: AnimationPlayer = kid.get_node("AnimationPlayer")
	# play walk animation
	animation.play("mixamo_com")
	# play footsteps sfx
	var footsteps_sfx: AudioStreamPlayer3D = kid.get_node("audio")
	footsteps_sfx.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if progress_ratio > 0.05 and progress_ratio < 0.1:
		play_wind_audio.emit()
	if progress_ratio == 1.0:
		level_complete.emit()


func _play_audio() -> void:
	wind_sfx.play()


func _on_level_complete() -> void:
	if not kid:
		return
	if kid.health > 0.0:
		level_successful.emit()
		on_level_successful()


func on_level_successful() -> void:
	var animation: AnimationPlayer = kid.get_node("AnimationPlayer")
	animation.stop()
	var footsteps_sfx: AudioStreamPlayer3D = kid.get_node("audio")
	footsteps_sfx.stop()
	
	camera.player = null
	camera.set_process_input(false)
	
	end_sequnce.play_cinematic()
