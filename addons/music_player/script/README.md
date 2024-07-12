# Documentation

Here's a thorough explanation on how to work with the MusicPlayer addon's classes and resources.

## MusicPlayer

The music player node is how music can be played with only one line of code.

**Properties**

`bus: String`: The bus used by all the child `AudioStreamPlayer` nodes. `Music` is the default.

`tracklist: Dictionary`: All of the tracks listed in tracklist.json. Each `TrackInfo` is accessible with a track's name.

### _ready()

**Description:**

Deserializes tracklist.json, parses every TrackInfo object, and puts each of them into the `tracklist` dictionary.

### load_track()

**Description:**

Loads a track from tracklist.json and sets it as the current track.

**Parameters:**

`trackname: String`: The name of the track as named in tracklist.json.

`vol: float`: The starting volume of the track. Default is 1.0.

`autoplay: bool`: Set it to true should the track play upon loading. Default is false.

### unload_track()

**Description:**

Unloads the current track and removes it from the scene tree.

### fade_to_track()

**Description:**

Do a fade transition from the current track to the new track. The new track gets set as the new current track and plays automatically.

**Parameters:**

`trackname`: The name of the track as named in tracklist.json.

`vol`: The starting volume of the track. Default is 1.0.

`duration`: How long the fade should last.

### play()

**Description:**

Plays the current track from the beginning.

### pause()

**Description:**

Pauses or unpauses playback of the current track.

### stop()

**Description:**

Stops any playback of the current track.

### get_current_track() -> Track

**Description:**

Gets the track currently being used.

**Returns:**

The node of the current track.



## Track

An instance of music with multiple layers playing simultaneously.

**Properties:**

`track_info: TrackInfo`: The info of the track

`volume: float`: How loud the track is

`playing: bool`: Whether or not the track and its layers are playing.

`stream_paused: bool`: Whether or not the track and its layers are paused.

`fade_finished: signal`: Emitted when a volume fade for the track is finished.

### _ready()

**Description:**

Upon ready, the track should be provided a TrackInfo resource. If it exists, then the node should create the AudioStreamPlayer nodes for each of the individual layers.

### play()

**Description:**

Plays all of the layers that are children of the track.

### pause()

**Description:**

Pauses playback of the layers of the track.

### stop()

**Description:**

Stops all playback of the layers of the track.

### set_layer_volume()

**Description:**

Sets the volume of a specific layer to the provided normalized float volume.

**Parameters:**

`layer: int`: The layer index to change the volume.

`vol: float`: The normalized volume level to set for the specified layer.

### fade_volume()

**Description:**

Fades the volume of the current track to the specified volume over the given duration. If `duration` is 0, then the volume is instantly set to `vol`.

**Parameters:**

`vol: float`: The target volume to fade to.

`duration: float`: The duration of the fade (default is 1.0).

### fade_layer_volume();

**Description:**

Fades the volume of the specified layer to the specified volume over the given duration. If `duration` is 0, then the volume is instantly set to `vol`.

**Parameters:**

`layer: int`: The layer index to change the volume.

`vol: float`: The target volume to fade to.

`duration: float`: The duration of the fade (default is 1.0).

### fade_out()

**Description:**

Fades the volume of the current track out to 0 and then stops it. If the duration is approximately zero, it stops immediately.

**Parameters:**

`duration: float`: The duration of the fade out (default is 1.0).

### get_layer_count() -> int

**Description:**

Returns the number of layers in the track.

**Returns:**

An integer representing the number of layers.

### is_playing() -> bool

**Description:**

Checks if the track is currently playing.

**Returns:**

Returns true if the track is playing. False if not.

### is_stream_paused() -> bool

**Description:**

Checks if the track is currently paused.

**Returns:**

Returns true if the track is paused. False if not.



## TrackInfo

**Description:**

A resource that contains information on a track.

**Properties:**

`name: String`: The name of the track

`layer_count: int`: How many layers play in this track

`stream: Array[String]`: An array of paths to each of the layers