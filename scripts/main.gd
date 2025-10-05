class_name Main extends Node2D

@onready var player_collection: PlayerCollection = $PlayerCollection
@onready var card_selection: CardSelection = $CardSelection
@onready var mini_game_win_screen: MiniGameWinScreen = $MiniGameWinScreen
@onready var children_container: Control = $Playground/ChildrenContainer

@export var mini_games : Array[MiniGame]
@export var editor_size : Vector2

@export_category("Emojis")
@export var emoji_sad_texture : Texture
@export var emoji_ok_texture : Texture
@export var emoji_happy_texture : Texture
@export var emoji_exclamation : Texture
@export var emoji_cross : Texture

const CARD_CONTROL = preload("res://scenes/card_control.tscn")
const CHILD_CONTROL = preload("res://scenes/child_control.tscn")

var cards : Array[CardResource]
var children : Array[ChildResource]
var last_mini_game: MiniGame
var last_opponent: Child

var _difficulty = 0.0
var max_difficulty = 3.0
var difficulty : int :
	get: return _difficulty / max_difficulty

func _ready():
	load_cards()
	load_children()
	
func load_children():
	for file_name in DirAccess.get_files_at("res://assets/resources/children/"):
		if (file_name.get_extension() == "tres"):
			children.append(ResourceLoader.load("res://assets/resources/children/"+file_name))
			
func load_cards():
	for file_name in DirAccess.get_files_at("res://assets/resources/cards/"):
		if (file_name.get_extension() == "tres"):
			cards.append(ResourceLoader.load("res://assets/resources/cards/"+file_name))

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
	children_container.remove_child(child)

func from_editor_to_viewport_position(pos):
	return pos / editor_size * Vector2(get_viewport().size)
	
func get_editor_to_viewport_ratio():
	return get_viewport().size.length() / editor_size.length()

signal difficulty_changed()
signal mini_game_ended(mini_game: MiniGame)
signal mini_game_started(mini_game: MiniGame)
