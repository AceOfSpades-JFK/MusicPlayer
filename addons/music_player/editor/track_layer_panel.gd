@tool
extends MarginContainer
class_name TrackLayerPanel

@export var _name_label: Label
@export var _meta_label: Label
@export var _mute_button: CheckBox


var track_info: TrackInfo
var layer_index: int

signal mute_toggled(toggled_on: bool, layer_index: int)


func _ready() -> void:
	if track_info:
		_name_label.text = track_info.stream[layer_index]


func _on_mute_box_toggled(toggled_on: bool) -> void:
	if track_info:
		mute_toggled.emit(toggled_on, layer_index)
