extends Control

@onready var victory: Label = $CenterContainer/Victory
@onready var healthbar: Control = $MarginContainer/healthbar

#@onready var healthbar: ProgressBar = $BoxContainer/ProgressBar
@export var kid: Kid
@export var follow_path: PathFollow3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthbar.max_value = kid.max_health
	follow_path.level_successful.connect(_display_label)

func _display_label() -> void:
	healthbar.visible = false
	await get_tree().create_timer(3.5).timeout
	victory.visible = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if kid:
		healthbar.value = kid.max_health - kid.health
