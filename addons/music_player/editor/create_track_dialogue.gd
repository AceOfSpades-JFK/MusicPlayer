@tool
extends ConfirmationDialog

@onready var _name_edit: TextEdit		= %NameEdit
@onready var _artist_edit: TextEdit		= %ArtistEdit
@onready var _bpm_edit: TextEdit		= %BPMEdit
@onready var _beat_count_edit: TextEdit	= %BeatCountEdit

signal created(t: TrackInfo)


func set_fields(t: TrackInfo) -> void:
	_name_edit.text = t.name
	_artist_edit.text = t.artist
	_bpm_edit.text = str(t.bpm)
	_beat_count_edit.text = str(t.beat_count)


func _ready() -> void:
	get_cancel_button().pressed.connect(_on_cancel_button_pressed)
	get_ok_button().pressed.connect(_on_create_button_pressed)


func _on_cancel_button_pressed() -> void:
	close_requested.emit()
	_clear_fields()


func _generate_track_info() -> TrackInfo:
	var t: TrackInfo = TrackInfo.new()
	t.name = _name_edit.text
	t.artist = _artist_edit.text
	t.bpm = _bpm_edit.text.to_float()
	t.beat_count = _beat_count_edit.text.to_int()
	return t


func _on_create_button_pressed() -> void:
	created.emit(_generate_track_info())
	_on_cancel_button_pressed()


func _clear_fields() -> void:
	_name_edit.text = ""
	_artist_edit.text = ""
	_bpm_edit.text = ""
