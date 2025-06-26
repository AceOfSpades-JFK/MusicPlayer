@tool
extends Control

var _panel_ps: PackedScene = preload("res://addons/music_player/editor/track_layer_panel.tscn")
var _track_ps: PackedScene = preload("res://addons/music_player/editor/track_panel.tscn")
var _create_track_ps: PackedScene = preload("res://addons/music_player/editor/create_track_dialogue.tscn")
var _edit_track_ps: PackedScene = preload("res://addons/music_player/editor/edit_track_dialogue.tscn")

var _music_player: MusicPlayer

var _track_container_path: NodePath = "SplitContainer/Tracklist/BoxContainer/TrackContainer"
var _layer_container_path: NodePath = "SplitContainer/WorkArea/MarginContainer/VBoxContainer2/LayerContainer"
var _tracklist_file_dialogue_path: NodePath = "TrackListLoadDialogue"
var _stream_layer_dialogue_path: NodePath = "StreamLayerLoadDialogue"
var _load_button_path: NodePath = "SplitContainer/Tracklist/BoxContainer/TracklistLoadContainer/BoxContainer/LoadButton"
var _save_button_path: NodePath = "SplitContainer/Tracklist/BoxContainer/TracklistLoadContainer/BoxContainer/SaveButton"
var _saveas_button_path: NodePath = "SplitContainer/Tracklist/BoxContainer/TracklistLoadContainer/BoxContainer/SaveAsButton"
var _tracklist_label_path: NodePath = "SplitContainer/Tracklist/BoxContainer/TracklistLoadContainer/TracklistLabel"
var _controls_path: NodePath = "SplitContainer/WorkArea/MarginContainer/VBoxContainer2/Controls"
var _create_window_path: NodePath = "CreateTrackDialogue"

@onready var _track_container: Container = get_node(_track_container_path)
@onready var _layer_container: Container = get_node(_layer_container_path)
@onready var _tracklist_file_dialogue: FileDialog = get_node(_tracklist_file_dialogue_path)
@onready var _stream_layer_dialogue: FileDialog = get_node(_stream_layer_dialogue_path)
@onready var _load_button: Button = get_node(_load_button_path)
@onready var _save_button: Button = get_node(_save_button_path)
@onready var _saveas_button: Button = get_node(_saveas_button_path)
@onready var _tracklist_label: Label = get_node(_tracklist_label_path)
@onready var _controls: Control = get_node(_controls_path)

var _tracklist_file: StringName = ""
var _playing: bool = false
var _first_play: bool = false
var _dragging: bool = false
var _dirty_tracklist: bool = false
var _window: Window
var _track_info_dialog: ConfirmationDialog
var _track_editing: StringName = ""

var _current_track: Track:
	get:
		return _music_player.get_current_track()


func _enter_tree() -> void:
	_music_player = MusicPlayer.new()
	add_child(_music_player)


# func _ready() -> void:
# 	_load_tracks()	


func _add_track_panel(t: TrackInfo) -> void:
	var p = _track_ps.instantiate()
	p.track_info = t
	p.open.connect(_on_track_open)
	p.remove_requested.connect(_on_track_removed)
	p.edit_requested.connect(_on_track_editing)
	_track_container.add_child(p)


func _load_tracks() -> void:
	var b: Button = Button.new()
	b.text = "+ Create Track"
	b.pressed.connect(_on_create_track_button_pressed)
	_track_container.add_child(b)
	_track_container.visible = true

	for k: String in _music_player.tracklist.keys():
		_add_track_panel(_music_player.tracklist[k])


func _add_track_layer_panel(t: TrackInfo, i: int) -> void:
	var p: TrackLayerPanel = _panel_ps.instantiate()
	p.track_info = t
	p.layer_index = i
	p.mute_toggled.connect(_on_layer_mute_toggled)
	p.removal_requested.connect(_on_layer_remove_requested)
	_layer_container.add_child(p)


func _load_layers(t: String) -> void:
	if t && !t.is_empty() && _music_player.tracklist.has(t):
		var i = 0
		for s: String in _music_player.tracklist[t].stream:
			_add_track_layer_panel(_music_player.tracklist[t], i)
			i += 1
	
	var b: Button = Button.new()
	b.text = "+ Add Layer"
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.pressed.connect(_on_add_layer_button_pressed)
	_layer_container.add_child(b)
	_layer_container.visible = true


func _on_layer_mute_toggled(muted: bool, layer_index: int) -> void:
	if muted:
		_current_track.set_layer_volume(layer_index, 0.0)
	else:
		_current_track.set_layer_volume(layer_index, 1.0)
	

func _on_track_open(tn: StringName) -> void:
	# Load the current track and stop playing the previous one
	if (!_music_player.load_track(tn, 1.0, false)):
		return
	
	# Load all the layer panels
	_clear_layers()
	_load_layers(tn)
	_controls.track = _current_track


func _on_load_button_pressed() -> void:
	_on_file_buttons_pressed(FileDialog.FILE_MODE_OPEN_FILE)


func _on_save_button_pressed() -> void:
	if !_tracklist_file.is_empty():
		_save_tracklist(_tracklist_file)
		_on_track_list_load_dialogue_canceled()
	else:
		_on_save_as_button_pressed()


func _on_save_as_button_pressed() -> void:
	_on_file_buttons_pressed(FileDialog.FILE_MODE_SAVE_FILE)


func _on_file_buttons_pressed(fm: FileDialog.FileMode) -> void:
	_tracklist_file_dialogue.file_mode = fm
	_tracklist_file_dialogue.popup_centered_ratio()
	_load_button.disabled = true
	_save_button.disabled = true
	_saveas_button.disabled = true


func _on_track_list_load_dialogue_canceled() -> void:
	var grey_save: bool = _dirty_tracklist || _tracklist_file.is_empty()
	_load_button.disabled = false
	_save_button.disabled = !grey_save
	_saveas_button.disabled = !grey_save


func _on_track_list_load_dialogue_file_selected(path: StringName) -> void:
	_tracklist_label.text = path
	_saveas_button.visible = true
	_dirty_tracklist = false
	_tracklist_file = path

	if _tracklist_file_dialogue.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		_music_player.load_tracklist(path)
		_clear_layers()
		_clear_tracks()
		_load_tracks()
	elif _tracklist_file_dialogue.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		_save_tracklist(path)
	
	_on_track_list_load_dialogue_canceled()


func _save_tracklist(path: StringName) -> void:
	var write_to = FileAccess.open(path, FileAccess.WRITE)
	var dic: Dictionary = {
		"version": 1,
		"tracks": []
	}

	for t: TrackInfo in _music_player.tracklist.values():
		dic["tracks"].append(t.serialize())
	
	var json_string = JSON.stringify(dic)
	write_to.store_line(json_string)
	_dirty_tracklist = false
	_tracklist_file = path


func _clear_layers() -> void:
	_controls.track = null
	_layer_container.get_children().all(func (c): c.queue_free(); return true)


func _clear_tracks() -> void:
	_track_container.get_children().all(func(c): c.queue_free(); return true)


func _on_add_layer_button_pressed() -> void:
	_stream_layer_dialogue.popup_centered()


func _on_create_track_button_pressed() -> void:
	_track_info_dialog = _create_track_ps.instantiate()
	_track_info_dialog.connect("created", _on_create_track_created)
	_track_info_dialog.close_requested.connect(_on_create_track_cancelled)
	add_child(_track_info_dialog)
	_track_info_dialog.popup_centered()


func _on_create_track_cancelled() -> void:
	_track_info_dialog.queue_free()


func _on_create_track_created(t: TrackInfo) -> void:
	_music_player.add_track(t)
	_add_track_panel(t)
	_track_info_dialog.queue_free()
	_dirty_tracklist = true
	_track_editing = ""
	_on_track_list_load_dialogue_canceled()


func _on_edit_track_applied(t: TrackInfo) -> void:
	# Maybe I should be doing this a different way...
	var tt = _music_player.tracklist[_track_editing]
	t.stream = tt.stream
	_music_player.modify_track(_track_editing, t)

	# if _track_editing != t.name:
	# 	_music_player.tracklist[t.name] = _music_player.tracklist[_track_editing]
	# 	_music_player.tracklist.erase(_track_editing)

	# Just reprint the track infos
	for c: Node in _track_container.get_children():
		if c.has_method("reprint_track_info"):
			c.call("reprint_track_info")

	_controls.set("track", _controls.get("track"))
	_track_info_dialog.queue_free()
	_dirty_tracklist = true
	_track_editing = ""
	_on_track_list_load_dialogue_canceled()


func _on_stream_layer_dialogue_file_selected(path: String) -> void:
	_current_track.track_info.stream.append(path)
	_on_track_open(_current_track.track_info.name)
	_dirty_tracklist = true
	_on_track_list_load_dialogue_canceled()
	

func _on_layer_remove_requested(index: int) -> void:
	_current_track.track_info.stream.remove_at(index)
	_on_track_open(_current_track.track_info.name)
	_dirty_tracklist = true
	_on_track_list_load_dialogue_canceled()


func _on_track_removed(tn: StringName):
	if _current_track && tn == _current_track.track_info.name:
		_clear_layers()
		
	_music_player.remove_track(tn)
	_clear_tracks()
	_load_tracks()
	_dirty_tracklist = true
	_on_track_list_load_dialogue_canceled()


func _on_track_editing(tn: StringName) -> void:
	_track_editing = tn
	
	_track_info_dialog = _edit_track_ps.instantiate()
	_track_info_dialog.connect("applied", _on_edit_track_applied)
	_track_info_dialog.close_requested.connect(_on_create_track_cancelled)
	add_child(_track_info_dialog)
	_track_info_dialog.call("set_fields", _music_player.tracklist[tn])
	_track_info_dialog.popup_centered()
