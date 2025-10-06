class_name PlayerCollection extends CanvasLayer

@onready var main : Main = $"/root/Main"

@export var cards : Array[CardResource]

@onready var open_collection: TextureRect = $OpenCollection
@onready var cards_control: Control = $CardsControl
@onready var cards_container: GridContainer = $CardsControl/ScrollContainer/CardsContainer

@onready var add_card_container: Control = $OpenCollection/AddCardContainer
@onready var add_card_target: Control = $OpenCollection/AddCardTarget

@export var bag_opened_texture: Texture
@export var bag_closed_texture: Texture

@onready var collection_stats_label: Label = $OpenCollection/CollectionStatsLabel
@onready var title_label: Label = $Level/LevelProgressBar/TitleLabel

const CARD_NODE = preload("res://scenes/card_node.tscn")

var card_for_levels = [8, 15]
var label_for_levels = ["Nobody", "Playa", "Wonder Kid", "Hero of the playground"]

func _ready() -> void:	
	open_collection.mouse_entered.connect(func():
		open_collection.material.set("shader_parameter/outline_size", 5.0)
	)
	open_collection.mouse_exited.connect(func():
		open_collection.material.set("shader_parameter/outline_size", 0.0)
	)
	open_collection.gui_input.connect(
		func(event: InputEventMouseButton):
			if event.is_pressed() and event.button_index == 1:
				cards_control.visible = not cards_control.visible
				open_collection.scale = Vector2(0.7, 1.5)
				open_collection.texture = bag_opened_texture if cards_control.visible else bag_closed_texture
	)
	main.ready.connect(func(): 
		card_for_levels.append(main.cards.size())
		update_cards_collection()
	)

func _process(delta):
	open_collection.scale = lerp(open_collection.scale, Vector2.ONE, delta * 10.0)
	level_progress_bar.value = lerp(level_progress_bar.value, current_progress_value, delta * 5.0)

func update_cards_collection():
	for card in cards_container.get_children():
		cards_container.remove_child(card)
	build_collection(cards_container)
	update_progress_bar()
	
func build_player_collection_controls(parent:Control):
	var cards_dict : Dictionary = {}
	for card in cards:
		if not cards_dict.has(card): cards_dict[card] = 0
		cards_dict[card] += 1
	for card in cards_dict.keys():
		var card_control = main.create_card_control(card, parent)
		card_control.set_count(cards_dict[card])

func build_collection(parent: Control):
	var cards_dict : Dictionary = {}

	for card in cards:
		if not cards_dict.has(card): cards_dict[card] = 0
		cards_dict[card] += 1
	
	var main_cards = main.cards.duplicate()
	main_cards.sort_custom(func(a, b): return b.card_rarity > a.card_rarity)
	for card in main_cards:
		var c = main.create_card_control(card, parent)
		if not cards_dict.has(card):
			c.set_unknown(true)
			pass
		else:
			c.set_count(cards_dict[card])

func add_card(card: CardResource):
	cards.append(card)
	update_cards_collection()
	var new_card = CARD_NODE.instantiate() as CardNode
	add_card_container.add_child(new_card)
	new_card.load_card_resource(card)
	get_tree().create_tween().tween_property(new_card, "global_position", add_card_target.global_position, 0.5)
	await get_tree().create_timer(0.5).timeout
	open_collection.scale = Vector2.ONE * 1.5
	add_card_container.remove_child(new_card)
		
func remove_card(card: CardResource):
	cards.erase(card)
	update_cards_collection()

	
@onready var level_progress_bar: TextureProgressBar = $Level/LevelProgressBar
@onready var stats_label: Label = $Level/LevelProgressBar/StatsLabel
var current_progress_value : float = 0.0
func update_progress_bar():
	var goal = card_for_levels[min(main._difficulty, card_for_levels.size() - 1)]
	var value = get_unique_cards_count()
	level_progress_bar.max_value = goal
	stats_label.text = str(value, "/", goal)
	current_progress_value = value
	collection_stats_label.text = str(value, "/", main.cards.size())
	title_label.text = label_for_levels[main._difficulty]
	
	if main._difficulty >= card_for_levels.size(): return;
	if value >= goal:
		main.up_difficulty()
		update_progress_bar()

func get_unique_cards_count():
	var cards_dict : Dictionary = {}
	for card in cards:
		if not cards_dict.has(card): cards_dict[card] = 0
		cards_dict[card] += 1
	return cards_dict.keys().size()
