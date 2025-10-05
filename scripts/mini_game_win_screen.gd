class_name MiniGameWinScreen extends CanvasLayer

@onready var main: Main = $/root/Main

@onready var return_button: CustomButton = $Container/HBoxContainer/ReturnButton
@onready var rematch_button: CustomButton = $Container/HBoxContainer/RematchButton
@onready var or_label: Label = $Container/HBoxContainer/OrLabel

@onready var center_container: CenterContainer = $Container/CenterContainer

@onready var particles: GPUParticles2D = $Container/Particles
@onready var title: Label = $Title

func _ready():
	return_button.pressed.connect(func():
		set_visible(false)
	)
	rematch_button.pressed.connect(func():
		set_visible(false)
		main.rematch()
	)
	particles.global_position = get_viewport().size / 2.0

func load_card(card: CardResource):
	var child = center_container.get_child(0)
	center_container.remove_child(child)
	main.create_card_control(card, center_container)

func open():
	set_visible(true)
	rematch_button.set_visible(main.last_opponent.cards.size())
	or_label.set_visible(main.last_opponent.cards.size())

func set_win():
	title.text = "YOU GOT A NEW CARD !"
	particles.emitting = true

func set_lose():
	title.text = "YOU LOST A CARD :("
	particles.emitting = false
