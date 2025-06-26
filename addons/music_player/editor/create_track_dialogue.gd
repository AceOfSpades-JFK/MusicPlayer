extends ConfirmationDialog

@onready var _name_edit: TextEdit	= %NameEdit
@onready var _artist_edit: TextEdit	= %ArtistEdit
@onready var _bpm_edit: TextEdit	= %BPMEdit

signal created(t: TrackInfo)


func _ready() -> void:
	get_cancel_button().pressed.connect(_on_cancel_button_pressed)
	get_ok_button().pressed.connect(_on_create_button_pressed)


func _on_cancel_button_pressed() -> void:
	close_requested.emit()
	_clear_fields()


func generate_track_info() -> TrackInfo:
	var t: TrackInfo = TrackInfo.new()
	t.name = _name_edit.text
	t.artist = _artist_edit.text
	t.bpm = _bpm_edit.text.to_float()
	return t


func _on_create_button_pressed() -> void:
	var t = generate_track_info()
	_on_cancel_button_pressed()


func _clear_fields() -> void:
	_name_edit.text = ""
	_artist_edit.text = ""
	_bpm_edit.text = ""
