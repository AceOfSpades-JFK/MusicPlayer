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


class Track:
	var name: String
	var stream: Array


### The tracklist for the current project
var tracklist: Dictionary

var _tracks_node: Node				# Use a node so that it can be easily cleared
var _layer_count: int = 0
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
			var newTrack = Track.new()
			newTrack.name = t["name"]
			newTrack.stream = t["stream"]
			tracklist[newTrack.name] = newTrack
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", file, " at line ", json.get_error_line())


func load_track(trackname: String, volume: float = 1.0) -> void:
	if tracklist.has(trackname):
		# Clear the entire trackspace
		if _tracks_node != null:
			_tracks_node.name = "__goodbye__"
			_tracks_node.queue_free()
		_tracks_node = Node.new()

		# Initialize private variables dedicated for playback
		var t: Track = tracklist[trackname]
		_tracks_node.name = t.name
		_volume = volume
		_layer_count = t.stream.size()
		_layer_volumes.clear()
		_layer_volumes.resize(_layer_count)
		_layer_volumes.fill(1.0)

		# Create the nodes of AudioStreamPlayers
		var i = 0
		for s in t.stream:
			var asp: AudioStreamPlayer = AudioStreamPlayer.new()
			asp.name = trackname + "#" + str(i)
			asp.stream = load(PATH_TO_MUSIC + t.stream[i])
			asp.bus = MUSIC_PLAYER_BUS
			asp.autoplay = true			# REMOVE THIS!!!
			asp.volume_db = lerp(MIN_DB, MAX_DB, sqrt(_layer_volumes[i] * volume))
			_tracks_node.add_child(asp)
			i += 1
		add_child(_tracks_node)
	return
