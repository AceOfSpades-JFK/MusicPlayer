extends MarginContainer

@onready var _name_edit: TextEdit	= $BoxContainer/NameContainer/TextEdit
@onready var _artist_edit: TextEdit	= $BoxContainer/ArtistContainer/TextEdit
@onready var _bpm_edit: TextEdit	= $BoxContainer/BPMContainer/TextEdit

signal cancelled()
signal created(t: TrackInfo)


func _on_cancel_button_pressed() -> void:
	cancelled.emit()


func _on_create_button_pressed() -> void:
	var t: TrackInfo = TrackInfo.new()
	t.name = _name_edit.text
	t.artist = _artist_edit.text
	t.bpm = _bpm_edit.text.to_float()
	created.emit(t)
