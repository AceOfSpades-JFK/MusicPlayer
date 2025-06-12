@tool
extends Control

var _panel_ps: PackedScene = preload("res://addons/music_player/editor/track_layer_panel.tscn")
var _track_ps: PackedScene = preload("res://addons/music_player/editor/track_panel.tscn")

var _music_player: MusicPlayer
var _current_track: String

@export var _track_container: NodePath
@export var _layer_container: NodePath


func _enter_tree() -> void:
	_music_player = MusicPlayer.new()
	add_child(_music_player)


func _ready() -> void:
	_load_tracks()	


func _load_tracks() -> void:
	for k: String in _music_player.tracklist.keys():
		var p: TrackPanel = _track_ps.instantiate()
		p.track_name = k
		get_node(_track_container).add_child(p)
		p.open.connect(_on_track_open)


func _load_layers(t: String) -> void:
	if t && !t.is_empty() && _music_player.tracklist.has(t):
		for s: String in _music_player.tracklist[t].stream:
			var p: TrackLayerPanel = _panel_ps.instantiate()
			p.file_name = s
			get_node(_layer_container).add_child(p)
	

func _on_track_open(tn: String) -> void:
	get_node(_layer_container).get_children().all(func (c): c.queue_free(); return true)
	_load_layers(tn)
	_current_track = tn
