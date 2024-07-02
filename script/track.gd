extends Node
class_name Track

const MUSIC_PLAYER_BUS: String = "Music"
const PATH_TO_MUSIC: String = "res://asset/music/"

# 0.0 --------------------- 1.0
#  ^                         ^
# Totally                  Fully
#  Mute                   Audible
const MAX_DB = 0.0
const MIN_DB = -80.0

@export var track_info: TrackInfo
var volume: float = 1.0

var _layers: Array[AudioStreamPlayer]
var _layer_volumes: Array[float]
var _tween: Tween
var _layer_tweens: Array[Tween]

var playing: bool = false
var stream_paused: bool = false

signal fade_finished


func _ready():
	if track_info:
		# Initialize any layers
		_layers.resize(track_info.layer_count)
		_layer_volumes.resize(track_info.layer_count)
		_layer_volumes.fill(1.0)
		_layer_tweens.resize(track_info.layer_count)

		# Create the nodes of AudioStreamPlayers
		var i = 0
		for s in track_info.stream:
			var asp: AudioStreamPlayer = AudioStreamPlayer.new()
			asp.name = track_info.name + "#" + str(i)
			asp.stream = load(PATH_TO_MUSIC + track_info.stream[i])
			asp.bus = MUSIC_PLAYER_BUS
			asp.volume_db = _calculate_db(_layer_volumes[i] * volume)
			add_child(asp)
			_layers[i] = asp
			i += 1
	else:
		printerr("No track info found!")
		queue_free()


func _process(_delta):
	# Apply the global volume
	_apply_volume()


func play() -> void:
	for c: AudioStreamPlayer in get_children():
		c.play()
	playing = true
	stream_paused = false


func stop() -> void:
	for c: AudioStreamPlayer in get_children():
		c.stop()
	playing = false
	stream_paused = false


func pause() -> void:
	for c: AudioStreamPlayer in get_children():
		c.stream_paused = !c.stream_paused
	stream_paused = !stream_paused


### Sets the volume of a layer to the normalized float
#	layer: Which layer to change the volume
#	volume: How loud should the current layer be
func set_layer_volume(layer: int, vol: float) -> void:
	_layer_volumes[layer] = vol


### Fade the volume of the current track
#	vol: Volume to fade to
#	duration: How long the fade should last (default is 1.0)
func fade_volume(vol: float, duration: float = 1.0) -> void:
	if duration > 0.0:
		if _tween:
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(self, "volume", vol, duration)
		_tween.tween_callback(_fade_finished_emit)
	else:
		volume = vol
		_fade_finished_emit()


### Fade the current track out and stop it
#	duration: How long the fade should last (default is 1.0)
func fade_out(duration: float = 1.0) -> void:
	if is_zero_approx(duration):
		stop()
	else:
		fade_volume(0.0, duration)
		_tween.tween_callback(stop)


### Return how many layers there are in the track
#	Returns: The number of layers
func get_layer_count() -> int:
	return track_info.layer_count
	

#########################################################################################
#
#	Private functions
#

func _calculate_db(normal_volume: float) -> float:	
	return lerp(MIN_DB, MAX_DB, pow(normal_volume, 1.0/5.0))


func _apply_volume() -> void:
	var i = 0
	for asp in get_children():
		if asp is AudioStreamPlayer:
			asp.volume_db = _calculate_db(_layer_volumes[i] * volume)
		i += 1

func _fade_finished_emit() -> void:
	fade_finished.emit()
