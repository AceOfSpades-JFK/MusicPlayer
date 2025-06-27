@tool
extends MarginContainer

@onready var _track_label: Label  = $MarginContainer/BoxContainer/TrackLabel
@onready var _controls_container  = $MarginContainer/BoxContainer/HBoxContainer
@onready var _time_slider: Slider = $MarginContainer/BoxContainer/HBoxContainer/TimeSlider
@onready var _time_label:  Label  = $MarginContainer/BoxContainer/HBoxContainer/TimeLabel

var track: Track:
	set(v):
		if track != v:
			reset()
		if track:
			track.finished.disconnect(reset)
		
		if v:
			_track_label.text = "Now playing: %s - %s" % [v.track_info.name, v.track_info.artist]
			_play_button.disabled = false
			_stop_button.disabled = false
			_time_slider.editable = true
			v.finished.connect(reset)
		else:
			_track_label.text = ""
			_play_button.disabled = true
			_stop_button.disabled = true
			_time_slider.editable = false
		track = v

var _playing: bool = false:
	set(v):
		_playing = v
		if Engine.is_editor_hint():
			_play_button.text = ""
			if !v:
				_play_button.icon = EditorInterface.get_editor_theme().get_icon("Play", "EditorIcons")
			else:
				_play_button.icon = EditorInterface.get_editor_theme().get_icon("Pause", "EditorIcons")
		else:
			_play_button.icon = null
			if !v:
				_play_button.text = "Play"
			else:
				_play_button.text = "Pause"

var _first_play: bool = false
var _dragging: bool = false
var _play_button: Button
var _stop_button: Button

signal play_pressed(paused: bool)
signal stop_pressed()
signal seeked(new_value: float)


func _enter_tree() -> void:
	_play_button = Button.new()
	_play_button.pressed.connect(_on_play_pause_button_pressed)

	_stop_button = Button.new()
	_stop_button.pressed.connect(_on_stop_button_pressed)


func _ready() -> void:
	_ready_deferred.call_deferred()


func _ready_deferred() -> void:
	_controls_container.add_child(_play_button)
	_controls_container.add_child(_stop_button)
	_controls_container.move_child(_play_button, 0)
	_controls_container.move_child(_stop_button, 1)
	track = track
	_playing = _playing
	if Engine.is_editor_hint():
		_stop_button.icon = EditorInterface.get_editor_theme().get_icon("Stop", "EditorIcons")
	else:
		_stop_button.text = "Stop"


func _process(delta: float) -> void:
	# Display time information on the controls
	if track:
		# Label text
		var seconds = "%0*d" % [2, int(track.time) % 60]
		_time_label.text = str("%d:%s | %d:%d" % [\
			int(track.time / 60.0), \
			seconds, \
			track.measure, \
			track.beat, \
		])

		# Slider position
		if !_dragging:
			_time_slider.value = track.time / track.length


func _on_play_pause_button_pressed() -> void:
	if _playing:
		# _play_button.icon = EditorInterface.get_base_control().get_icon("Play", "EditorIcons")
		track.pause()
	else:
		# _play_button.icon = EditorInterface.get_base_control().get_icon("Pause", "EditorIcons")
		if !_first_play:
			track.play()
			_first_play = true
		else:
			track.pause()
	
	_playing = !_playing
	play_pressed.emit(_playing)


func reset() -> void:
	_play_button.icon = EditorInterface.get_editor_theme().get_icon("Play", "EditorIcons")
	_time_slider.value = 0.0
	_first_play = false
	_playing = false


func _on_time_slider_drag_ended(value_changed: bool) -> void:
	if _dragging && value_changed && track:
		if !_first_play:
			_on_play_pause_button_pressed()
		track.seek(_time_slider.value * track.length)
		_dragging = false


func _on_time_slider_drag_started() -> void:
	if !_dragging:
		_dragging = true


func _on_stop_button_pressed() -> void:
	stop_pressed.emit()
	track.stop()
	reset()
