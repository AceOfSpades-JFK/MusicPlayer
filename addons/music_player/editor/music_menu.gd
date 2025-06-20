@tool
extends Control

var _panel_ps: PackedScene = preload("res://addons/music_player/editor/track_layer_panel.tscn")
var _track_ps: PackedScene = preload("res://addons/music_player/editor/track_panel.tscn")

var _music_player: MusicPlayer

@export var _track_container: NodePath
@export var _layer_container: NodePath
@export var _play_button: NodePath
@export var _stop_button: NodePath
@export var _time_label_path: NodePath
@export var _time_slider_path: NodePath

@onready var _time_label: Label = get_node(_time_label_path)
@onready var _time_slider: Slider = get_node(_time_slider_path)

var _playing: bool = false
var _first_play: bool = false
var _dragging: bool = false

var _current_track: Track:
	get:
		return _music_player.get_current_track()


func _enter_tree() -> void:
	_music_player = MusicPlayer.new()
	add_child(_music_player)


func _ready() -> void:
	_load_tracks()	


func _process(delta: float) -> void:
	# Display time information on the controls
	if _current_track:
		# Label text
		var seconds = "%0*d" % [2, int(_current_track.time) % 60]
		_time_label.text = str("%d:%s | %d:%d" % [\
			int(_current_track.time / 60.0), \
			seconds, \
			_current_track.measure, \
			_current_track.beat, \
		])

		# Slider position
		if !_dragging:
			_time_slider.value = _current_track.time / _current_track.length


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

	# Load the current track and stop playing the previous one
	_music_player.load_track(tn, 1.0, false)
	_on_stop_button_pressed()
	_current_track.finished.connect(_on_stop_button_pressed)


func _on_play_pause_button_pressed() -> void:
	_toggle_play(!_playing)


func _toggle_play(b: bool) -> void:
	if _playing:
		get_node(_play_button).text = "Play"
		_music_player.pause()
	else:
		get_node(_play_button).text = "Pause"
		if _first_play:
			_music_player.pause()
		else:
			_first_play = true
			_music_player.play()
	_playing = b


func _on_stop_button_pressed() -> void:
	get_node(_play_button).text = "Play"
	_music_player.stop()
	_playing = false
	_first_play = false
	_time_slider.value = 0


func _on_time_slider_drag_ended(value_changed: bool) -> void:
	if _dragging && value_changed:
		_current_track.seek(_time_slider.value * _current_track.length)
		_dragging = false


func _on_time_slider_drag_started() -> void:
	if !_dragging:
		_dragging = true
