extends Resource
class_name TrackInfo

var name: StringName
var artist: StringName
var bpm: float
var stream: Array

var layer_count: int:
	get: return stream.size()

func serialize() -> Dictionary:
	return {
		"name": name,
		"artist": artist,
		"bpm": bpm,
		"stream": stream
	}


func transfer(t: TrackInfo) -> void:
	name = t.name
	artist = t.artist
	bpm = t.bpm
	stream = t.stream
