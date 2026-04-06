extends Node3D

@onready var canopy: MeshInstance3D = $canopy
var canopy_anim_value: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	canopy_anim_value = canopy.get_blend_shape_value(0)
	print(canopy_anim_value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
