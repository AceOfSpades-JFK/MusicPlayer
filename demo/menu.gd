extends Control


@onready var volume_slider: HSlider = $VBoxContainer/HBoxContainer/VolumeSlider


func _on_regal_pressed():
	$MusicPlayer.load_track("Regal", volume_slider.value)


func _on_hell_pressed():
	$MusicPlayer.load_track("Hell", volume_slider.value)


func _on_volume_slider_drag_ended(value_changed):
	if value_changed:
		if $MusicPlayer.get_child_count():
			$MusicPlayer.set_volume(volume_slider.value)
