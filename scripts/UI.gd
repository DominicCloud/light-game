extends Control


@export var credits: VBoxContainer
@onready var healthbar: Control = $MarginContainer/healthbar
@onready var bg_rect: ColorRect = $ColorRect

@export var kid: Kid
@export var follow_path: PathFollow3D


func _ready() -> void:
	healthbar.max_value = kid.max_health
	follow_path.level_successful.connect(_disable_UI)

func _disable_UI() -> void:
	healthbar.visible = false

func display_credits() -> void:
	# Mute all other audio (ice-cream truck, wind, etc)
	#AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	bg_rect.visible = true
	credits.modulate.a = 0.0
	credits.visible = true
	var tween_in = create_tween()
	tween_in.tween_property(credits, "modulate:a", 1.0, 0.5)
	await tween_in.finished
	await get_tree().create_timer(5.0).timeout
	var tween_out = create_tween()
	tween_out.tween_property(credits, "modulate:a", 0.0, 1.0)
	var music_out = create_tween()
	music_out.tween_property(bg_music, "volume_db", -80.0, 3.5)
	await tween_out.finished
	await music_out.finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if kid:
		healthbar.value = kid.max_health - kid.health
