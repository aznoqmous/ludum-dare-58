class_name CardNode extends Node2D
@onready var sprite: Sprite2D = $Sprite

func load_card_resource(card: CardResource):
	sprite.texture = card.texture
