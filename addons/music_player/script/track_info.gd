extends Resource
class_name TrackInfo

var name: String
var artist: String
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
