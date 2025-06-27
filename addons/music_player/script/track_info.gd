extends Resource
class_name TrackInfo

var name: String
var artist: String
var bpm: float
var beat_count: int
var stream: Array

var layer_count: int:
	get: return stream.size()

func serialize() -> Dictionary:
	return {
		"name": name,
		"artist": artist,
		"beat_count": beat_count,
		"bpm": bpm,
		"stream": stream
	}


func transfer(t: TrackInfo) -> void:
	name = t.name
	artist = t.artist
	bpm = t.bpm
	beat_count = t.beat_count
	stream = t.stream
