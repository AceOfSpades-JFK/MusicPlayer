extends Node
class_name MusicPlayer

const PATH_TO_MUSIC: String = "res://asset/music/"
const PATH_TO_TRACKLIST: String = "res://tracklist.json"
const MUSIC_PLAYER_BUS: String = "Music"

var tracklist: Dictionary

class Track:
	var name: String
	var stream: Array


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

	#call_deferred("load_track", "Regal")


func load_track(trackname: String) -> void:
	if tracklist.has(trackname):
		var t: Track = tracklist[trackname]
		var i = 0
		for s in t.stream:
			var asp: AudioStreamPlayer = AudioStreamPlayer.new()
			asp.name = trackname + "#" + str(i)
			asp.stream = load(PATH_TO_MUSIC + t.stream[i])
			asp.bus = MUSIC_PLAYER_BUS
			#asp.autoplay = true
			add_child(asp)
			i += 1
		
