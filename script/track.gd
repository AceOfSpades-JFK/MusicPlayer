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
var _layer_tween: Tween
var _prev_vol: float


func _ready():
	if track_info:
		_layers.resize(track_info.layer_count)
		_layer_volumes.resize(track_info.layer_count)
		_layer_volumes.fill(1.0)
		# Create the nodes of AudioStreamPlayers
		var i = 0
		for s in track_info.stream:
			var asp: AudioStreamPlayer = AudioStreamPlayer.new()
			asp.name = track_info.name + "#" + str(i)
			asp.stream = load(PATH_TO_MUSIC + track_info.stream[i])
			asp.bus = MUSIC_PLAYER_BUS
			asp.autoplay = true			# REMOVE THIS!!!
			asp.volume_db = _calculate_db(_layer_volumes[i] * volume)
			add_child(asp)
			_layers[i] = asp
			i += 1
	else:
		printerr("No track info found!")
		queue_free()


func _process(_delta):
	# Apply the global volume upon tweening
	if volume != _prev_vol:
		_apply_volume()
	
	# Apply the layer volume upon tweening
	pass

	_prev_vol = volume


### Sets the volume of a layer to the normalized float
#	layer: Which layer to change the volume
#	volume: How loud should the current layer be
func set_layer_volume(layer: int, vol: float) -> void:
	_layer_volumes[layer] = vol
	_apply_layer_volume(layer)


func fade_volume(vol: float, duration: float = 1.0) -> void:
	if duration > 0.0:
		if _tween:
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(self, "volume", vol, duration)
	else:
		volume = vol


func get_layer_count():
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


func _apply_layer_volume(layer: int) -> void:
	var asp: AudioStreamPlayer = get_children()[layer]
	asp.volume_db = _calculate_db(_layer_volumes[layer] * volume)
	pass
