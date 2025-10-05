extends Node2D
@onready var main: Main = $"/root/Main"
@onready var clouds: Control = $CanvasLayer/Clouds

func _ready() -> void:
	main.from_editor_to_viewport_transform(clouds)
	
