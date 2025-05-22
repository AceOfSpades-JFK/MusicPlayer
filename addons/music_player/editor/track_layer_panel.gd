@tool
extends MarginContainer

@onready var _name_label: Label = $BoxContainer/LayerInfo/FileContents/Name
@onready var _meta_label: Label = $BoxContainer/LayerInfo/FileContents/Meta
@onready var _mute_button: CheckBox = $BoxContainer/LayerControls/CheckBox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
