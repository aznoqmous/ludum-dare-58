extends CanvasLayer
@onready var play_button: CustomButton = $Control/PlayButton

func _ready():
	play_button.pressed.connect(func():
		set_visible(false)
	)
