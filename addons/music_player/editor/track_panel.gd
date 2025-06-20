@tool
extends MarginContainer
class_name TrackPanel

@export var _name_label: Label
@export var _meta_label: Label

signal open(tn: String)

var track_info: TrackInfo


func _ready() -> void:
	_name_label.text = track_info.name
	_meta_label.text = "%s \n %sBPM" % [track_info.artist, track_info.bpm]
	pass


func _on_open_button_pressed() -> void:
	open.emit(track_info.name)
