extends PathFollow3D

signal level_complete
signal play_wind_audio
signal level_successful
@onready var wind_sfx: AudioStreamPlayer = $AudioStreamPlayer

@export var kid: Kid
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_complete.connect(_on_level_complete)
	play_wind_audio.connect(_play_audio)
	
	await get_tree().create_timer(2.0).timeout
	create_tween().tween_property(self, "progress_ratio", 1, 60)
	var animation: AnimationPlayer = kid.get_node("AnimationPlayer")
	# play walk animation
	animation.play("mixamo_com")
	# play footsteps sfx
	var footsteps_sfx: AudioStreamPlayer3D = kid.get_node("audio")
	footsteps_sfx.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if progress_ratio == 0.05:
		play_wind_audio.emit()
		print("playing wind audio")

	if progress_ratio == 1.0:
		level_complete.emit()

func _play_audio() -> void:
	wind_sfx.play()


func _on_level_complete() -> void:
	var animation: AnimationPlayer = kid.get_node("AnimationPlayer")
	if kid.health > 0.0:
		level_successful.emit()
	animation.stop()
