@tool
extends MarginContainer

const POPUP_ID_REMOVE: int = 1

@export var _name_label: Label
@export var _meta_label: Label
@export var _mute_button: CheckBox
@export var _menu_button: MenuButton

var _waveform: TextureRect

var track_info: TrackInfo
var layer_index: int

signal mute_toggled(toggled_on: bool, layer_index: int)
signal removal_requested(index: int)


func _enter_tree() -> void:
	# Generate preview using FFMPEG
	#  Os.execute() doesn't really sound like a good idea ngl, but i'd rather not make someone compile something for a small feature
	if track_info:
		# Generate the necessary files
		var preview_path = 'user://preview_%s_%s.png' % [track_info.name, layer_index]
		var in_path  = ProjectSettings.globalize_path(track_info.stream[layer_index])
		var out_path = ProjectSettings.globalize_path(preview_path)
		OS.execute("ffmpeg", ["-i", in_path, "-filter_complex", "compand,showwavespic=s=1000x50:colors=#e0e0e0", "-frames:v", "1", out_path], []) 

		# Access the files
		if FileAccess.file_exists(preview_path):
			_waveform = TextureRect.new()
			var image = Image.load_from_file(preview_path)
			_waveform.texture = ImageTexture.create_from_image(image)
			# _waveform.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_waveform.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			_waveform.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
			


func _ready() -> void:
	if track_info:
		_name_label.text = track_info.stream[layer_index]
	_menu_button.get_popup().id_pressed.connect(_on_menu_button_pressed)
	_ready_deferred.call_deferred()


func _ready_deferred() -> void:
	if _waveform:
		$BoxContainer/LayerInfo/Panel.add_child(_waveform)


func _on_mute_box_toggled(toggled_on: bool) -> void:
	if track_info:
		mute_toggled.emit(toggled_on, layer_index)


func _on_menu_button_pressed(id: int) -> void:
	match id:
		POPUP_ID_REMOVE:
			removal_requested.emit(layer_index)
