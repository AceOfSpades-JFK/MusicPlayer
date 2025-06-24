extends Window

@onready var _name_edit: TextEdit	= %NameEdit
@onready var _artist_edit: TextEdit	= %ArtistEdit
@onready var _bpm_edit: TextEdit	= %BPMEdit
@onready var _cancel_button: Button = $MarginContainer/BoxContainer/ButtonsContainer/CancelButton
@onready var _create_button: Button = $MarginContainer/BoxContainer/ButtonsContainer/CreateButton

signal cancelled()
signal created(t: TrackInfo)


func _ready() -> void:
	_cancel_button.pressed.connect(_on_cancel_button_pressed)
	_create_button.pressed.connect(_on_create_button_pressed)


func _on_cancel_button_pressed() -> void:
	cancelled.emit()
	close_requested.emit()
	_clear_fields()


func _on_create_button_pressed() -> void:
	var t: TrackInfo = TrackInfo.new()
	t.name = _name_edit.text
	t.artist = _artist_edit.text
	t.bpm = _bpm_edit.text.to_float()
	created.emit(t)
	close_requested.emit()
	_clear_fields()


func _clear_fields() -> void:
	_name_edit.text = ""
	_artist_edit.text = ""
	_bpm_edit.text = ""
