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


### Loads the track with the provided volume and sets it as the current track
#	trackname: Name of the track to load
#	volume: How loud the track should be (default is 1.0)
func load_track(trackname: String, vol: float = 1.0) -> void:
	if tracklist.has(trackname):
		# Get the track info, create the track node, and add it to the scene tree
		var ti = tracklist[trackname]
		var t: Track = Track.new()
		t.name = ti.name
		t.track_info = ti
		t.volume = vol
		add_child(t)
		_current_track = t


func unload_track() -> void:
	var t: Track = _get_track("")
	if t:
		if t == _current_track:
			_current_track = null
		t.name = '__goodbye__'
		t.queue_free()


func play() -> void:
	var t: Track = _get_track("")
	if t:
		t.play()


func stop() -> void:
	var t: Track = _get_track("")
	if t:
		t.stop()


func get_current_track() -> Track:
	return _current_track


func _get_track(trackname: String) -> Track:
	# If no track name is given, return the current track
	if trackname.is_empty():
		return _current_track

	# If a track name is given, return the specified track
	elif has_node(trackname):
		return get_node(trackname)

	# Or just print this error
	else:
		printerr("Track (" + trackname + ") is not currently loaded!")
		return null
