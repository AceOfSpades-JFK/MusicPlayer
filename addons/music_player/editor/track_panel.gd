@tool
extends MarginContainer
class_name TrackPanel

@export var _name_label: Label
@export var _meta_label: Label

signal open(tn: String)

var track_name: String:
	get: 
		return track_name
	set(value): 
		track_name = value
		_name_label.text = value


func _on_open_button_pressed() -> void:
	open.emit(track_name)
