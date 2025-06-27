@tool
extends MarginContainer

const POPUP_ID_REMOVE: int = 1

@export var _name_label: Label
@export var _meta_label: Label
@export var _mute_button: CheckBox
@export var _menu_button: MenuButton

var track_info: TrackInfo
var layer_index: int

signal mute_toggled(toggled_on: bool, layer_index: int)
signal removal_requested(index: int)


func _ready() -> void:
	if track_info:
		_name_label.text = track_info.stream[layer_index]
	_menu_button.get_popup().id_pressed.connect(_on_menu_button_pressed)


func _on_mute_box_toggled(toggled_on: bool) -> void:
	if track_info:
		mute_toggled.emit(toggled_on, layer_index)


func _on_menu_button_pressed(id: int) -> void:
	match id:
		POPUP_ID_REMOVE:
			removal_requested.emit(layer_index)
