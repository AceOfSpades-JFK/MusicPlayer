@tool
extends MarginContainer
class_name TrackLayerPanel

@export var _name_label: Label
@export var _meta_label: Label
@export var _mute_button: CheckBox

var file_name:
	get: return _name_label.text
	set(value): _name_label.text = value
