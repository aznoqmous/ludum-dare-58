extends CanvasLayer
@onready var play_button: CustomButton = $Control/PlayButton
@onready var title: TextureRect = $Control/BigCloud/Title
@onready var main: Main = $"/root/Main"
func _ready():
	title.pivot_offset *= main.get_editor_to_viewport_ratio()
	play_button.pressed.connect(func():
		set_visible(false)
	)
