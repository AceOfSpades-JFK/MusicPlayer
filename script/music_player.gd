extends Node
class_name MusicPlayer

const PATH_TO_TRACKLIST: String = "res://tracklist.json"

# 0.0 --------------------- 1.0
#  ^                         ^
# Totally                  Fully
#  Mute                   Audible
const MAX_DB = 0.0
const MIN_DB = -80.0

### The tracklist for the current project
var tracklist: Dictionary

var _current_track: Track


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
		if _current_track:
			_current_track.name = '__goodbye__'
			_current_track.queue_free()
		
		# Get the track info, create the track node, and add it to the scene tree
		var ti = tracklist[trackname]
		var t: Track = Track.new()
		t.name = ti.name
		t.track_info = ti
		t.volume = vol
		add_child(t)
		_current_track = t


func get_current_track() -> Track:
	return _current_track
