@tool
extends EditorPlugin

const AUTOLOAD_NAME = "GlobalMusicPlayer"


# Initialization
func _enter_tree():
	# Adds the music player type
	add_custom_type("MusicPlayer", "Button", preload("script/music_player.gd"), preload("icon.svg"))
	
	# Adds the music player as an autoload
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/music_player/script/music_player.gd")


# De-initialization
func _exit_tree():
	remove_custom_type("MyButton")
	remove_autoload_singleton(AUTOLOAD_NAME)
