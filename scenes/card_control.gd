class_name CardControl extends Control

@onready var background: TextureRect = $AspectRatioContainer/Control/Background
@onready var picture: TextureRect = $AspectRatioContainer/Control/Picture
@onready var picture_shadow: TextureRect = $AspectRatioContainer/Control/PictureShadow
@onready var name_label: Label = $AspectRatioContainer/Control/NameLabel
@onready var colors: TextureRect = $AspectRatioContainer/Control/Colors
@onready var ribbon: TextureRect = $AspectRatioContainer/Control/Ribbon
@onready var card_count: Label = $AspectRatioContainer/Control/CardCount
@onready var description: Label = $AspectRatioContainer/Control/Description
@onready var power_label: Label = $AspectRatioContainer/Control/StarControl/PowerLabel
@onready var rarity_label: Label = $AspectRatioContainer/Control/RarityLabel

@export var enabled_color : Color
@export var disabled_color : Color
@onready var control: Control = $AspectRatioContainer/Control

@onready var star_control: Control = $AspectRatioContainer/Control/StarControl
@onready var star_shadow: TextureRect = $AspectRatioContainer/Control/StarControl/StarShadow
@onready var star: TextureRect = $AspectRatioContainer/Control/StarControl/Star
@onready var unknown_card_texture: TextureRect = $AspectRatioContainer/Control/UnknownCardTexture

var card_resource: CardResource

var enabled := true
var selected := true
var hovered := false
var shuffle_win_card := false

func _ready():
	mouse_entered.connect(func():
		hovered = true
		hover.emit()
		z_index = 1
	)
	mouse_exited.connect(func():
		hovered = false
		z_index = 0
	)
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		if not enabled: return
		click.emit()

func _process(delta):
	scale = lerp(scale, Vector2.ONE * (1.1 if hovered else 1.0), delta * 10.0)
	if hovered: 
		star.rotation += delta
		star_shadow.rotation = star.rotation

func select():
	selected = true
	background.material.set("shader_parameter/outline_size", 5)
	
func unselect():
	selected = false
	background.material.set("shader_parameter/outline_size", 0)

func enable():
	enabled = true
	modulate = enabled_color
	
func disable():
	enabled = false
	modulate = disabled_color

func load_card_resource(cr: CardResource):
	card_resource = cr
	name_label.text = card_resource.name
	power_label.text = str(card_resource.power)
	picture.texture = card_resource.texture
	picture_shadow.texture = card_resource.texture
	colors.modulate = card_resource.color
	ribbon.modulate = card_resource.color
	background.modulate = card_resource.rarity_color
	description.text = card_resource.description
	background.material.set("shader_parameter/shade_color", card_resource.rarity_color)
	background.material.set("shader_parameter/outline_color", card_resource.color)
	rarity_label.label_settings.outline_color = card_resource.color
	rarity_label.text = ["COMMON", "RARE", "EPIC"][card_resource.card_rarity]

signal click()
signal hover()

func set_unknown(value: bool):
	unknown_card_texture.set_visible(value)
	star_control.set_visible(not value)

func set_count(value):
	card_count.set_visible(value > 1)
	card_count.text = str("x", value)
