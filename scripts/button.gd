@tool
class_name CustomButton extends MarginContainer
@onready var label: Label = $Label
@onready var nine_patch_rect: NinePatchRect = $Label/Container/NinePatchRect

var hovered := false
@export var disabled : bool = false :
	set(value):
		disabled = value
		update_colors()

@export var text: String = "Placeholder" :
	set(value):
		text = value
		if label:
			label.text = value
			pivot_offset = size / 2.0

@export var background_color : Color = Color.GRAY :
	set(value):
		background_color = value
		update_colors()

@export var text_color : Color = Color.WHITE :
	set(value):
		text_color = value
		update_colors()

@export var disabled_background_color : Color = Color.DIM_GRAY
@export var disabled_text_color : Color = Color.GRAY

func _ready():
	label.text = text
	nine_patch_rect.modulate = background_color
	label.modulate = text_color
	
	mouse_entered.connect(func(): hovered = true)
	mouse_exited.connect(func(): hovered = false)
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		if disabled: return;
		pressed.emit()

func _process(delta):
	scale = lerp(scale, Vector2.ONE * (1.1 if hovered else 1.0), delta * 10.0)
	
func update_colors():
	if nine_patch_rect: nine_patch_rect.modulate = disabled_background_color if disabled else background_color
	if label: label.modulate = disabled_text_color if disabled else text_color

signal pressed()
