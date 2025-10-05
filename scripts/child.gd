class_name Child extends Control

@onready var main: Main = $"/root/Main"
@onready var label: Label = $Label
@onready var sprite_2d: TextureRect = $SpriteContainer/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bubble: TextureRect = $SpriteContainer/Bubble
@onready var emoji: TextureRect = $SpriteContainer/Bubble/Emoji

@export var cards : Array[CardResource]
@export var child_resource: ChildResource

var hovered : bool = false
var outline_size := 0.0

func _ready():
	mouse_entered.connect(func():
		hovered = true
	)
	mouse_exited.connect(func():
		hovered = false
	)
	
	main.ready.connect(func():
		if child_resource: load_child_resource(child_resource)
		else: pick_cards()
	)
	
	global_position = main.from_editor_to_viewport_position(global_position)
	scale *= main.get_editor_to_viewport_ratio()
	
	animation_player.play("idle")
	animation_player.advance(randf_range(0, animation_player.current_animation.length()))

func _process(delta):
	if hovered:
		outline_size = abs(sin(main.get_time() * TAU)) * 6.0
	else:
		outline_size = lerp(outline_size, 0.0, delta * 10.0)
	sprite_2d.material.set("shader_parameter/outline_size", outline_size)
	
	bubble.scale = lerp(bubble.scale, Vector2.ONE, delta * 10.0)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1 and hovered:
		main.card_selection.open(self)
		hide_bubble()
		
func load_child_resource(cr: ChildResource):
	child_resource = cr
	sprite_2d.texture = cr.texture
	label.text = cr.name
	pick_cards()

func pick_cards():
	cards.clear()
	var copy_cards = main.cards.duplicate()
	copy_cards.shuffle()
	cards = copy_cards.slice(0, 3)
	set_bubble(main.emoji_exclamation)

func set_bubble(emoji_texture:Texture, timeout:float=0.0):
	bubble.set_visible(true)
	emoji.texture = emoji_texture
	bubble.scale = Vector2(0.75, 1.25)
	if timeout:
		await main.wait(timeout)
		bubble.set_visible(false)

func hide_bubble():
	bubble.set_visible(false)
