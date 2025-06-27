extends Control

var _dragging: bool = false
@onready var volume_slider: HSlider = $VBoxContainer/HBoxContainer/VolumeSlider
@onready var _music_player: MusicPlayer = $MusicPlayer

func _on_regal_pressed():
	_change_track("Regal")


func _on_hell_pressed():
	_change_track("Hell")


func _change_track(track_name):
	# Prepare the layer grid node
	if has_node("VBoxContainer/LayerGrid"):
		$VBoxContainer/LayerGrid.queue_free()
		$VBoxContainer/LayerGrid.name = "__goodbye__"
	var lg: GridContainer =  GridContainer.new()
	lg.name = "LayerGrid"

	# Load and play the track
	_music_player.fade_to_track(track_name, volume_slider.value, 2.0)

	# Something
	for i in range(_music_player.get_current_track().get_layer_count()):
		var cb: CheckBox = CheckBox.new()
		cb.name = str(i)
		cb.button_pressed = true
		cb.text = str(i)
		cb.pressed.connect(_on_checkbox_pressed)
		lg.add_child(cb)
	$VBoxContainer.add_child(lg)


func _on_checkbox_pressed():
	var i: int = 0
	for cb: CheckBox in $VBoxContainer/LayerGrid.get_children():
		var f: float = 1.0
		if !cb.button_pressed:
			f = 0.0
		_music_player.get_current_track().set_layer_volume(i, f)
		i += 1 
	
	
func _on_volume_slider_drag_ended(_value_changed):
	_dragging = false

func _process(_delta):
	if _dragging:
		if _music_player.get_current_track():
			_music_player.get_current_track().volume = volume_slider.value
	pass

func _on_volume_slider_drag_started():
	_dragging = true


func _on_fade_pressed():
	volume_slider.value = $VBoxContainer/HBoxContainer2/FadeVolumeSpinBox.value
	_music_player.get_current_track().fade_volume($VBoxContainer/HBoxContainer2/FadeVolumeSpinBox.value, 1.0)


func _on_play_pressed():
	_music_player.play()


func _on_stop_pressed():
	_music_player.stop()


func _on_pause_pressed():
	_music_player.pause()

func _on_fade_out_pressed():
	_music_player.get_current_track().fade_out()
