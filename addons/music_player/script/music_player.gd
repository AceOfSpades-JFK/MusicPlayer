@icon("res://addons/music_player/assets/music-albums-fill.svg")
extends Node
class_name MusicPlayer

const CURRENT_VERSION: int = 1
const PATH_TO_TRACKLIST: String = "res://tracklist.json"

# 0.0 --------------------- 1.0
#  ^                         ^
# Totally                  Fully
#  Mute                   Audible
const MAX_DB = 0.0
const MIN_DB = -80.0

### The audio bus to use for the music
@export var bus: StringName = "Music"
@export var json_path: StringName = PATH_TO_TRACKLIST

### The tracklist for the current project
var tracklist: Dictionary
var _current_track: Track

signal loaded_tracklist
signal unloaded_tracklist
signal loaded_track(track_name: StringName)
signal unloaded_track(unloaded_track_name: StringName)


# func _ready():
# 	load_tracklist(PATH_TO_TRACKLIST)


### Load the tracklist
func load_tracklist(filepath: StringName) -> bool:
	# Load the JSON file as a string
	var file = FileAccess.open(filepath, FileAccess.READ)
	if !file:
		push_error("File %s not found!" % filepath)
		return false
	var content = file.get_as_text()
	
	# Parse the JSON file
	var json = JSON.new()
	var newTracklist: Dictionary
	if json.parse(content) == OK:
		var data = json.data

		# Format checking
		if !data.has("tracks") || !data.has("version"):
			push_error("Improper formatting for tracklist at %s" % filepath)
			return false
		if data["version"] > CURRENT_VERSION:
			push_error("Incompatible version for tracklist at %s!" % filepath)
			return false
		if data["version"] < CURRENT_VERSION:
			push_warning("Tracklist at %s is an older version. Here be dragons!" % filepath)

		# Loop through all the tracks and put them in the tracklist dictionary
		var tracks = data["tracks"]
		for t in tracks:
			if !_is_track_dictionary_valid(t):
				push_error("Invalid track format in tracklist at %s!" % filepath)
				return false
			var newTrack = TrackInfo.new()
			newTrack.name = t["name"]
			newTrack.artist = t["artist"]
			newTrack.bpm = t["bpm"]
			newTrack.beat_count = t["beat_count"]
			newTrack.stream = t["stream"]
			newTracklist[newTrack.name] = newTrack
			
	else:
		push_error("JSON Parse Error: ", json.get_error_message(), " in ", file, " at line ", json.get_error_line())
		return false
	
	loaded_tracklist.emit()
	json_path = filepath
	
	# Clear the tracklist if it exists
	if !tracklist.is_empty():
		tracklist.clear()
	
	# Unload the current track
	unload_track()

	tracklist = newTracklist
	return true


### Checks if the tracklist has a track that goes by the passed in name
#	tn: The name of the track you want to check for
#	Returns true if the tracklist has that track
func has_track(tn: StringName) -> bool:
	return tracklist.has(tn)
	

### Adds a new track to the tracklist
#	t: Info of the track you want to add
#	Returns true upon success
func add_track(t: TrackInfo) -> bool:
	if has_track(t.name):
		return false
	
	tracklist[t.name] = t
	return true


### Removes a track based on the passed track name
#	tn: Name of the track you want removed
#	Returns the removed track info
func remove_track(tn: StringName) -> TrackInfo:
	if has_track(tn):
		var ti: TrackInfo = tracklist[tn]
		tracklist.erase(tn)
		if _current_track && _current_track.track_info.name == tn:
			unload_track()
		return ti
	return null


### Modifies a track with the passed in TrackInfo
#	tn: Name of the track you want to modify
#	ti: The track info to 
#	Returns the modified track info
func modify_track(tn: StringName, ti: TrackInfo) -> TrackInfo:
	if has_track(tn):
		tracklist[tn].transfer(ti)
		if tn != ti.name:
			tracklist[ti.name] = tracklist[tn]
			tracklist.erase(tn)
		return tracklist[ti.name]
	return null


### Loads a track from tracklist.json and sets it as the current track.
#	trackname: Name of the track to load
#	volume: How loud the track should be (default is 1.0)
#	autoplay: Should the track play upon loading (default is true)
#	Returns true on success
func load_track(trackname: String, vol: float = 1.0, autoplay: bool = true) -> bool:
	if has_track(trackname):
		#if _current_track && _current_track.name == trackname:
			## Ignore if the provided track is already the thing
			#print("Track (" + trackname + ") is already loaded!")
			#return false
		#else:
		# Unload the current track
		unload_track()

		# Create the track node
		var t: Track = _create_track_node(trackname)
		t.volume = vol
		t.bus = bus

		# Add the newly created track to the scene tree, and set it as the current track
		add_child(t)
		if autoplay: t.play()
		_current_track = t
		loaded_track.emit(trackname)
	else:
		printerr("Track (" + trackname + ") does not exist!")
		return false
	
	return true
	

### Fades the current track to a new track
#	trackname: Name of the track to fade to
#	vol: Volume to fade the new track to
#	duration: How long the track should fade
#	Returns true on success
func fade_to_track(trackname: String, vol: float = 1.0, duration: float = 1.0) -> bool:
	var old_t: = _current_track.name
	var queue_current_track_free: Callable = func():
		unloaded_track.emit(old_t)

	if has_track(trackname):
		# Fade out the old track
		if _current_track:
			# Return if the provided trackname is the current track!
			if _current_track.name == trackname:
				print("Track (" + trackname + ") is already loaded!")
				return false
			
			# Fade the previous track out
			_current_track.fade_finished.connect(_current_track.queue_free)
			_current_track.fade_finished.connect(queue_current_track_free)
			_current_track.fade_out(duration)
			_current_track.name = '__goodbye__'

		# Create a new track that fades in
		var t: Track = _create_track_node(trackname)
		t.volume = 0.0
		t.bus = bus

		# Add the newly created track to the scene tree, and set it as the current track
		add_child(t)
		t.play()
		t.fade_volume(vol, duration)
		_current_track = t
		
	else:
		printerr("Track (" + trackname + ") does not exist!")
		return false
	
	return true


### Unloads the current track.
func unload_track() -> void:
	if _current_track:
		unloaded_track.emit(_current_track.name)
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


func _is_track_dictionary_valid(t: Dictionary) -> bool:
	var keys = ['name', 'artist', 'bpm', 'beat_count', 'stream']
	return t.keys().all(func(k): return keys.has(k))


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
	var ti: TrackInfo = tracklist[trackname]
	var t: Track = Track.new()
	t.name = ti.name
	t.track_info = ti
	return t
