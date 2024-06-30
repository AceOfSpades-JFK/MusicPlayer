extends Control


var _dragging: bool = false
@onready var volume_slider: HSlider = $VBoxContainer/HBoxContainer/VolumeSlider


func _on_regal_pressed():
	_change_track("Regal")


func _on_hell_pressed():
	_change_track("Hell")


func _change_track(track_name):
	$MusicPlayer.load_track(track_name, volume_slider.value)


func _on_volume_slider_drag_ended(_value_changed):
	_dragging = false

func _process(_delta):
	if _dragging:
		if $MusicPlayer.get_child_count():
			$MusicPlayer.set_volume(volume_slider.value)
	pass

func _on_volume_slider_drag_started():
	_dragging = true
