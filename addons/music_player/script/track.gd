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
@export var bus: String = "Music"
var volume: float = 1.0 :
	set(val):
		volume = val
		if (_stream):
			_stream.volume_db = _calculate_db(val)


var _stream: AudioStreamPlayer
var _streamlist: AudioStreamSynchronized
var _layer_volumes: Array[float]
var _tween: Tween
var _layer_tweens: Array[Tween]

var playing: bool = false :
	set(val):
		playing = val
		if _stream:
			if val:
				_stream.play()
			else:
				_stream.stop()


var stream_paused: bool = false :
	set(val):
		stream_paused = val
		if _stream:
			_stream.stream_paused = val

signal fade_finished


func _ready():
	if track_info:
		# Initialize any layers
		_layer_volumes.resize(track_info.layer_count)
		_layer_volumes.fill(1.0)
		_layer_tweens.resize(track_info.layer_count)

		# Create the AudioStreamPlayer node
		_stream = AudioStreamPlayer.new()
		_stream.name = track_info.name
		_stream.bus = MUSIC_PLAYER_BUS
		add_child(_stream)

		# Create the AudioStreamSynchronized streamlist
		var i = 0
		_streamlist = AudioStreamSynchronized.new()
		_streamlist.stream_count = track_info.stream.size()
		_stream.stream = _streamlist
		for s in track_info.stream:
			var stream = load(PATH_TO_MUSIC + track_info.stream[i])
			_streamlist.set_sync_stream(i, stream)
			_streamlist.set_sync_stream_volume(i, _calculate_db(_layer_volumes[i]))
			i += 1
	else:
		printerr("No track info found!")
		queue_free()


# func _process(_delta):
# 	# Apply the global and layer volumes
# 	if _tween.is_running():
# 		_apply_volume()


### Plays each of the layers of the track
func play() -> void:
	playing = true


### Stops playback of each layer of the track
func stop() -> void:
	playing = false


### Pauses playback of the track layers
func pause() -> void:
	stream_paused = !stream_paused


### Sets the volume of a layer to the provided normalized float volume
#	layer: Which layer to change the volume
#	volume: How loud should the current layer be
func set_layer_volume(layer: int, vol: float) -> void:
	_stream.stream.set_sync_stream_volume(layer, _calculate_db(vol))
	_layer_volumes[layer] = vol


### Fade the volume of the current track
#	vol: Volume to fade to
#	duration: How long the fade should last (default is 1.0)
func fade_volume(vol: float, duration: float = 1.0) -> void:
	if duration > 0.0:
		if _tween:
			_tween.kill()
		for t: Tween in _layer_tweens:
			if t:
				t.kill()
		_tween = create_tween()
		_tween.tween_property(self, "volume", vol, duration)
		_tween.tween_property(_stream, "volume_db", _calculate_db(vol), duration)
		_tween.tween_callback(fade_finished.emit)
	else:
		volume = vol
		fade_finished.emit()


### Fade the volume of the given layer
#	layer: Which layer to fade
#	vol: Volume to fade to
#	duration: How long the fade should last (default is 1.0)
func fade_layer_volume(layer: int, vol: float, duration: float = 1.0) -> void:
	# _layer_volumes[layer] = vol
	# if duration > 0.0:
	# 	if _layer_tweens[layer]:
	# 		_layer_tweens[layer].kill()
	# 	_layer_tweens[layer] = create_tween()
	# 	_layer_tweens[layer].set_trans(Tween.TRANS_CIRC)
	# 	_layer_tweens[layer].tween_property(_stream.stream, "volume_db", _calculate_db(vol * volume), duration)
	# 	_layer_tweens[layer].tween_callback(fade_finished.emit)
	# else:
	# 	_apply_volume()
	# 	fade_finished.emit()
	pass


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

### Checks if the track is currently playing
#	Returns: A boolean to show if the track is playing
func is_playing() -> bool:
	return playing

### Checks if the track is currently paused
#	Returns: A boolean to show if the track is paused
func is_stream_paused() -> bool:
	return stream_paused
	

#########################################################################################
#
#	Private functions
#

func _calculate_db(normal_volume: float) -> float:	
	return lerp(MIN_DB, MAX_DB, pow(normal_volume, 1.0/10.0))


func _apply_volume() -> void:
	pass
