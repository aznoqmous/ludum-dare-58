class_name MiniGameTransition extends CanvasLayer

@onready var main: Main = $"/root/Main"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var control: Panel = $Control

@onready var background: TextureRect = $"Background"
@onready var opponent_texture: TextureRect = $Control/Control/Opponent/TextureRect

func _ready():
	control.global_position = main.from_editor_to_viewport_position(control.global_position)
