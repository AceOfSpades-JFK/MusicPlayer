@tool
extends Control

var _panel_ps: PackedScene = preload("res://addons/music_player/editor/track_layer_panel.tscn")
var _track_ps: PackedScene = preload("res://addons/music_player/editor/track_panel.tscn")

var _music_player: MusicPlayer

@export var _track_container_path: NodePath
@export var _layer_container_path: NodePath
@export var _tracklist_file_dialogue_path: NodePath
@export var _load_button_path: NodePath
@export var _save_button_path: NodePath
@export var _saveas_button_path: NodePath
@export var _tracklist_label_path: NodePath
@export var _controls_path: NodePath

@onready var _track_container: Container = get_node(_track_container_path)
@onready var _layer_container: Container = get_node(_layer_container_path)
@onready var _tracklist_file_dialogue: FileDialog = get_node(_tracklist_file_dialogue_path)
@onready var _load_button: Button = get_node(_load_button_path)
@onready var _save_button: Button = get_node(_save_button_path)
@onready var _saveas_button: Button = get_node(_saveas_button_path)
@onready var _tracklist_label: Label = get_node(_tracklist_label_path)
@onready var _controls: Control = get_node(_controls_path)

var _tracklist_file = ""
var _playing: bool = false
var _first_play: bool = false
var _dragging: bool = false
var _using_external_file: bool = false

var _current_track: Track:
	get:
		return _music_player.get_current_track()


func _enter_tree() -> void:
	_music_player = MusicPlayer.new()
	add_child(_music_player)


# func _ready() -> void:
# 	_load_tracks()	


func _load_tracks() -> void:
	for k: String in _music_player.tracklist.keys():
		var p: TrackPanel = _track_ps.instantiate()
		p.track_info = _music_player.tracklist[k]
		p.open.connect(_on_track_open)

		_track_container.add_child(p)


func _load_layers(t: String) -> void:
	if t && !t.is_empty() && _music_player.tracklist.has(t):
		var i = 0
		for s: String in _music_player.tracklist[t].stream:
			var p: TrackLayerPanel = _panel_ps.instantiate()
			p.track_info = _music_player.tracklist[t]
			p.layer_index = i
			p.mute_toggled.connect(_on_layer_mute_toggled)
			
			_layer_container.add_child(p)
			i += 1
	
	var b: Button = Button.new()
	b.text = "+ Add Layer"
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	# b.pressed.connect()
	_layer_container.add_child(b)
	_layer_container.visible = true


func _on_layer_mute_toggled(muted: bool, layer_index: int) -> void:
	if muted:
		_current_track.set_layer_volume(layer_index, 0.0)
	else:
		_current_track.set_layer_volume(layer_index, 1.0)
	

func _on_track_open(tn: String) -> void:
	# Load the current track and stop playing the previous one
	if (!_music_player.load_track(tn, 1.0, false)):
		return
	
	# Load all the layer panels
	_clear_layers()
	_load_layers(tn)
	_controls.track = _current_track


func _on_load_tracklist_button_pressed() -> void:
	_tracklist_file_dialogue.popup_centered_ratio()
	_load_button.disabled = true
	_save_button.disabled = true
	_saveas_button.disabled = true


func _on_track_list_load_dialogue_canceled() -> void:
	_load_button.disabled = false
	_save_button.disabled = false
	_saveas_button.disabled = false


func _on_track_list_load_dialogue_file_selected(path: String) -> void:
	_on_track_list_load_dialogue_canceled()

	_tracklist_label.text = path
	_saveas_button.visible = true
	_using_external_file = true
	_tracklist_file = path

	_music_player.load_tracklist(path)
	_clear_layers()
	_clear_tracks()
	_load_tracks()


func _clear_layers() -> void:
	_controls.track = null
	_layer_container.get_children().all(func (c): c.queue_free(); return true)


func _clear_tracks() -> void:
	_controls.track = null
	_track_container.get_children().all(func(c): c.queue_free(); return true)
