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

		# Loop through all the tracks and put them in the tracklist dictionary
		for t in tracks:
			var newTrack = TrackInfo.new()
			newTrack.name = t["name"]
			newTrack.stream = t["stream"]
			newTrack.layer_count = t["stream"].size()
			tracklist[newTrack.name] = newTrack
			
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", file, " at line ", json.get_error_line())


### Loads a track from tracklist.json and sets it as the current track.
#	trackname: Name of the track to load
#	volume: How loud the track should be (default is 1.0)
#	autoplay: Should the track play upon loading (default is false)
func load_track(trackname: String, vol: float = 1.0, autoplay: bool = false) -> void:
	if tracklist.has(trackname):
		if _current_track && _current_track.name == trackname:
			# Ignore if the provided track is already the thing
			print("Track (" + trackname + ") is already loaded!")

		else:
			# Unload the current track
			unload_track()

			# Create the track node
			var t: Track = _create_track_node(trackname)
			t.volume = vol

			# Add the newly created track to the scene tree, and set it as the current track
			add_child(t)
			if autoplay: t.play()
			_current_track = t
	else:
		printerr("Track (" + trackname + ") does not exist!")
	

### Fades the current track to a new track
#	trackname: Name of the track to fade to
#	vol: Volume to fade the new track to
#	duration: How long the track should fade
func fade_to_track(trackname: String, vol: float = 1.0, duration: float = 1.0) -> void:
	if tracklist.has(trackname):
		# Fade out the old track
		if _current_track:
			# Return if the provided trackname is the current track!
			if _current_track.name == trackname:
				print("Track (" + trackname + ") is already loaded!")
				return
			
			# Fade the previous track out
			_current_track.fade_finished.connect(_current_track.queue_free)
			_current_track.fade_out(duration)
			_current_track.name = '__goodbye__'

		# Create a new track that fades in
		var t: Track = _create_track_node(trackname)
		t.volume = 0.0

		# Add the newly created track to the scene tree, and set it as the current track
		add_child(t)
		t.play()
		t.fade_volume(vol, duration)
		_current_track = t
		
	else:
		printerr("Track (" + trackname + ") does not exist!")


### Unloads the current track.
func unload_track() -> void:
	if _current_track:
		_current_track.name = '__goodbye__'
		_current_track.queue_free()
		_current_track = null


### Plays the current track from the beginning.
func play() -> void:
	if _current_track:
		_current_track.play()


### Pauses playback of the current track.
func pause() -> void:
	if _current_track:
		_current_track.pause()


### Stops the playback of the current track
func stop() -> void:
	if _current_track:
		_current_track.stop()


### Get the track currently playing
#	Returns: The current track
func get_current_track() -> Track:
	return _current_track
	

#########################################################################################
#
#	Private functions
#


func _get_loaded_track(trackname: String) -> Track:
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


func _create_track_node(trackname: String) -> Track:
	# Get the track info, create the track node, and add it to the scene tree
	var ti = tracklist[trackname]
	var t: Track = Track.new()
	t.name = ti.name
	t.track_info = ti
	return t
