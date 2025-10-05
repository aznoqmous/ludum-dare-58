class_name Main extends Node2D

@onready var player_collection: PlayerCollection = $PlayerCollection
@onready var card_selection: CardSelection = $CardSelection
@onready var mini_game_win_screen: MiniGameWinScreen = $MiniGameWinScreen
@onready var children_container: Control = $Playground/ChildrenContainer
var children : Array[Child]


@export var editor_size : Vector2

@export_category("MiniGames")
@export var mini_games : Array[MiniGame]

@export_category("Children")
@export var children_on_screen: int = 3

@export_category("Emojis")
@export var emoji_sad_texture: Texture
@export var emoji_ok_texture: Texture
@export var emoji_happy_texture: Texture
@export var emoji_exclamation: Texture
@export var emoji_cross: Texture

const CARD_CONTROL = preload("res://scenes/card_control.tscn")
const CHILD_CONTROL = preload("res://scenes/child_control.tscn")

var cards: Array[CardResource]
var epic_cards: Array[CardResource]
var rare_cards: Array[CardResource]
var common_cards: Array[CardResource]
var last_mini_game: MiniGame
var last_opponent: Child

var _difficulty = 0.0
var max_difficulty = 3.0
var difficulty : int :
	get: return _difficulty / max_difficulty

func _ready():
	load_cards()
	pick_starter_cards()
	
	for child in children_container.get_children():
		children.append(child)
		child.set_visible(false)
		
	children.shuffle()
	for child in children.slice(0, 3):
		child.set_visible(true)

func load_cards():
	for file_name in DirAccess.get_files_at("res://assets/resources/cards/"):
		if (file_name.get_extension() == "tres"):
			var card: CardResource = ResourceLoader.load("res://assets/resources/cards/"+file_name)
			cards.append(card)
			match card.card_rarity:
				CardResource.CARD_RARITY.COMMON:
					common_cards.append(card)
				CardResource.CARD_RARITY.RARE:
					rare_cards.append(card)
				CardResource.CARD_RARITY.EPIC:
					epic_cards.append(card)

func create_card_control(card_resource: CardResource, parent:Control) -> CardControl :
	var new_card := CARD_CONTROL.instantiate() as CardControl
	parent.add_child(new_card)
	new_card.load_card_resource(card_resource)
	return new_card

func get_time() -> float:
	return Time.get_ticks_msec() / 1000.0

func wait(time):
	await get_tree().create_timer(time).timeout

func start_mini_game(mini_game: MiniGame, player_card: CardResource, opponent_card: CardResource, opponent: Child):
	last_mini_game = mini_game
	last_opponent = opponent
	mini_game.start(player_card, opponent_card, opponent)

func rematch():
	card_selection.open(last_opponent)

func remove_children(child: Child):
	var children_copy = children.duplicate()
	children.shuffle()
	var new_child = children.duplicate().filter(func(c): return not c.visible)[0]
	child.set_visible(false)
	new_child.set_visible(true)

func from_editor_to_viewport_position(pos):
	return pos / editor_size * Vector2(get_viewport().size)
	
func get_editor_to_viewport_ratio():
	return get_viewport().size.length() / editor_size.length()

signal difficulty_changed()
signal mini_game_ended(mini_game: MiniGame)
signal mini_game_started(mini_game: MiniGame)

var common_drop_rates = [80, 45, 33]
var rare_drop_rates = [15, 45, 33]
var epic_drop_rates = [5, 10, 33]

func pick_cards(count:int=1):
	var cards : Array[CardResource] = []
	for i in range(0, count):
		var value = randf_range(0.0, 100.0)
		if value < epic_drop_rates[_difficulty]: cards.append(epic_cards.pick_random())
		elif value < rare_drop_rates[_difficulty] + epic_drop_rates[_difficulty]: cards.append(rare_cards.pick_random())
		else: cards.append(common_cards.pick_random())
	return cards

func pick_starter_cards():
	var cards : Array[CardResource] = []
	var commons = common_cards.duplicate()
	for i in range(0, 3):
		var a = commons.pick_random()
		cards.append(a)
		commons = commons.filter(func(b): return b.card_color != a.card_color)
	player_collection.cards = cards
