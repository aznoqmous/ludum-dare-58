class_name CardNode extends Node2D
@onready var sprite: Sprite2D = $Sprite
@onready var colors: Sprite2D = $Colors
@onready var ribbon: Sprite2D = $Ribbon
@onready var background: Sprite2D = $Background
@onready var impact_particles: GPUParticles2D = $ImpactParticles

func load_card_resource(card: CardResource):
	sprite.texture = card.texture
	colors.modulate = card.color
	ribbon.modulate = card.color
	background.modulate = card.rarity_color
