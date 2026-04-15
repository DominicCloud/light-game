extends Node

@onready var flower: TextureRect = $CanvasLayer/Control/HBox/Flower
@onready var label: Label = $CanvasLayer/Control/HBox/Label

var spin_speed: float = 22.0  # degrees per second
var time: float = 0.0

func _ready() -> void:
	await get_tree().process_frame
	flower.pivot_offset = flower.size / 2.0

func _process(delta: float) -> void:
	flower.rotation_degrees += spin_speed * delta
	# Full cycle every ~12 seconds, range 0.05–0.95 — very gentle
	time += delta
	label.modulate.a = sin(time * TAU * 0.25) * 0.45 + 0.5

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
