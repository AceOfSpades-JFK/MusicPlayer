@tool
extends MarginContainer
class_name TrackPanel

const _POPUP_ID_EDIT: int = 0
const _POPUP_ID_REMOVE: int = 1

@export var _name_label: Label
@export var _meta_label: Label
@onready var _menu_button: MenuButton = $HBoxContainer/MarginContainer/VBoxContainer/MenuButton

signal open(tn: StringName)
signal remove_requested(tn: StringName)
signal edit_requested(tn: StringName)

var track_info: TrackInfo


func _ready() -> void:
	reprint_track_info()
	_menu_button.get_popup().id_pressed.connect(_on_menu_button_pressed)


func _on_open_button_pressed() -> void:
	open.emit(track_info.name)


func _on_menu_button_pressed(id: int) -> void:
	match id:
		_POPUP_ID_EDIT:
			edit_requested.emit(track_info.name)
		_POPUP_ID_REMOVE:
			remove_requested.emit(track_info.name)
	

func reprint_track_info() -> void:
	assert(track_info)
	_name_label.text = track_info.name
	_meta_label.text = "%s \n%sBPM" % [track_info.artist, track_info.bpm]
