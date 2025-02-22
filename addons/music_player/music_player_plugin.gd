@tool
extends EditorPlugin

const AUTOLOAD_NAME = "GlobalMusicPlayer"
const MUSIC_MENU_SCENE = preload("res://addons/music_player/editor/music_menu.tscn")

var main_panel_instance


# Initialization
func _enter_tree():
	# Adds the music player type
	add_custom_type("MusicPlayer", "Node", preload("script/music_player.gd"), preload("icon.svg"))
	
	# Adds the music player as an autoload
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/music_player/script/music_player.gd")

	# Set up music manager menu
	main_panel_instance = MUSIC_MENU_SCENE.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)


# De-initialization
func _exit_tree():
	remove_custom_type("MusicPlayer")
	remove_autoload_singleton(AUTOLOAD_NAME)
	if main_panel_instance:
		main_panel_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name():
	return "Music Manager"


func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
