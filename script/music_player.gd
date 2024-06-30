extends Node
class_name MusicPlayer

const PATH_TO_MUSIC: String = "res://asset/music/"
const PATH_TO_TRACKLIST: String = "res://tracklist.json"
const MUSIC_PLAYER_BUS: String = "Music"

# 0.0 --------------------- 1.0
#  ^                         ^
# Totally                  Fully
#  Mute                   Audible
const MAX_DB = 0.0
const MIN_DB = -80.0


class TrackInfo:
	var name: String
	var layer_count: int
	var stream: Array


### The tracklist for the current project
var tracklist: Dictionary

var _track: TrackInfo
var _tracks_node: Node				# Use a node so that it can be easily cleared
var _volume: float = 1.0
var _layer_volumes: Array[float]


func _ready():
	# Load the JSON file as a string
	var file = FileAccess.open(PATH_TO_TRACKLIST, FileAccess.READ)
	var content = file.get_as_text()
	
	# Parse the JSON file
	var json = JSON.new()
	if json.parse(content) == OK:
		var data = json.data
		var tracks = data["tracks"]
		print(tracks)

		# Loop through all the tracks and put them in the tracklist dictionary
		for t in tracks:
			var newTrack = TrackInfo.new()
			newTrack.name = t["name"]
			newTrack.stream = t["stream"]
			newTrack.layer_count = t["stream"].size()
			tracklist[newTrack.name] = newTrack
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", file, " at line ", json.get_error_line())


### Loads the track and sets the volume of the current track
#	trackname: Name of the track to load
#	volume: How loud the track should be (default is 1.0)
func load_track(trackname: String, vol: float = 1.0) -> void:
	if tracklist.has(trackname):
		# Clear the entire trackspace
		if _tracks_node != null:
			_tracks_node.name = "__goodbye__"
			_tracks_node.queue_free()
		_tracks_node = Node.new()

		# Initialize private variables dedicated for playback
		_track = tracklist[trackname]
		_tracks_node.name = _track.name
		_volume = vol
		_layer_volumes.clear()
		_layer_volumes.resize(_track.layer_count)
		_layer_volumes.fill(1.0)

		# Create the nodes of AudioStreamPlayers
		var i = 0
		for s in _track.stream:
			var asp: AudioStreamPlayer = AudioStreamPlayer.new()
			asp.name = trackname + "#" + str(i)
			asp.stream = load(PATH_TO_MUSIC + _track.stream[i])
			asp.bus = MUSIC_PLAYER_BUS
			asp.autoplay = true			# REMOVE THIS!!!
			asp.volume_db = _calculate_db(_layer_volumes[i] * vol)
			_tracks_node.add_child(asp)
			i += 1
		add_child(_tracks_node)
	return


### Sets the volume of the whole track to the normalized float
#	volume: How loud should the current track be
func set_volume(vol: float) -> void:
	_volume = vol
	var i = 0
	for asp in get_node(_track.name).get_children():
		if asp is AudioStreamPlayer:
			asp.volume_db = _calculate_db(_layer_volumes[i] * vol)
		i += 1


### Sets the volume of a layer to the normalized float
#	layer: Which layer to change the volume
#	volume: How loud should the current layer be
func set_layer_volume(layer: int, vol: float) -> void:
	var asp: AudioStreamPlayer = get_node(_track.name).get_children()[layer]
	asp.volume_db = _calculate_db(vol * _volume)
	_layer_volumes[layer] = vol


func get_current_track() -> TrackInfo:
	return _track


func get_layer_count() -> int:
	return _track.layer_count
	

#########################################################################################
#
#	Private functions
#


func _calculate_db(normal_volume: float) -> float:	
	return lerp(MIN_DB, MAX_DB, pow(normal_volume, 1.0/7.0))
