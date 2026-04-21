extends Node

#@onready var flower: TextureRect = $CanvasLayer/Control/HBox/Flower
#@onready var label: Label = $CanvasLayer/Control/HBox/Label
@onready var load_percentage: Label = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/loadPercentage
@onready var flower: TextureRect = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/HBox/Flower
@onready var label: Label = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/HBox/Label


var main_level_path: String = "res://scenes/main.tscn"
var progress: Array
var spin_speed: float = 22.0  # degrees per second
var time: float = 0.0
var is_loaded: bool = false

func _ready() -> void:
	await get_tree().process_frame
	flower.pivot_offset = flower.size / 2.0
	
	ResourceLoader.load_threaded_request(main_level_path)

func _process(delta: float) -> void:
	flower.rotation_degrees += spin_speed * delta
	# Full cycle every ~12 seconds, range 0.05–0.95 — very gentle
	time += delta
	label.modulate.a = sin(time * TAU * 0.25) * 0.45 + 0.5
	
	var status = ResourceLoader.load_threaded_get_status(main_level_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			load_percentage.text = "Loading..." + str(round(progress[0] * 100))+ "%"

		ResourceLoader.THREAD_LOAD_LOADED:
			if is_loaded:
				return
			load_percentage.text = "100%"
			await get_tree().create_timer(.5).timeout
			is_loaded = true
			load_percentage.text = ""
			# 3. Retrieve the scene and switch
			#var new_scene = ResourceLoader.load_threaded_get(main_level_path)
			#get_tree().change_scene_to_packed(new_scene)
			#set_process(false) # Stop polling

		ResourceLoader.THREAD_LOAD_FAILED:
			load_percentage.text = "Loading failed!"


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		get_tree().change_scene_to_file(main_level_path)
