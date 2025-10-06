class_name CardBattle extends MiniGame

@onready var player_cards_container: HBoxContainer = $Container/PlayerCards/PlayerCardsContainer
@onready var opponent_cards_container: HBoxContainer = $Container/OpponentCards/OpponentCardsContainer
@export var opponent_cards: Array[CardControl]
@export var player_cards: Array[CardControl]
@onready var center: Control = $Container/Center

var center_card : CardControl

var player_cards_count = 3
var mode: Mode = Mode.OpponentTurn

enum Mode {
	PlayerTurn,
	OpponentTurn
}

func _ready():
	for card in player_cards_container.get_children():
		card as CardControl
		card.click.connect(func():
			play_card(card)
		)

func on_start():
	center_card = null
	
	player_cards.clear()
	for card_control in player_cards_container.get_children():
		player_cards.append(card_control as CardControl)
		card_control.set_visible(true)
	
	opponent_cards.clear()
	for card_control in opponent_cards_container.get_children():
		opponent_cards.append(card_control as CardControl)
		card_control.set_visible(true)
		card_control.set_unknown()

	
	opponent_cards.shuffle()
	var random_cards = main.pick_cards(2)
	opponent_cards[0].load_card_resource(random_cards[0])
	opponent_cards[1].load_card_resource(random_cards[1])
	opponent_cards[2].load_card_resource(opponent_card)
	
	player_cards.shuffle()
	random_cards = main.player_collection.cards.duplicate()
	random_cards.erase(player_card)
	random_cards.shuffle()
	random_cards = random_cards.slice(0, player_cards_count - 1)
	if random_cards.size() > 0: player_cards[0].load_card_resource(random_cards[0])
	if random_cards.size() > 1: player_cards[1].load_card_resource(random_cards[1])
	player_cards[2].load_card_resource(player_card)
	
	await main.wait(0.5)
	opponent_turn()

func opponent_turn():
	mode = Mode.OpponentTurn
	play_card(opponent_cards.pick_random())

func player_turn():
	mode = Mode.PlayerTurn
	
func play_card(card: Control):
	player_cards_container.z_index = 1.0 if mode == Mode.PlayerTurn else 0.0
	opponent_cards_container.z_index = 1.0 if mode == Mode.OpponentTurn else 0.0
	get_tree().create_tween().tween_property(
		card, "global_position", 
		center.global_position - card.size / 2.0 + Vector2.RIGHT.rotated(randf_range(0.0, TAU) * randf_range(20.0, 200.0)), 
		0.3
	)
	card.set_unknown(false)
	await main.wait(0.3)
	card.play_particles()
	await main.wait(0.5)
	
	if not center_card:
		center_card = card
		card.z_index = 0.0
		mode = Mode.PlayerTurn if mode == Mode.OpponentTurn else Mode.OpponentTurn
		return
	
	if center_card.card_resource.power <= card.card_resource.power or center_card.card_resource.color == card.card_resource.color:
		remove_card(center_card)
		center_card = card
		if opponent_cards.size() <= 0:
			return await win()
		if player_cards.size() <= 0:
			return await lose()
		if mode == Mode.PlayerTurn: opponent_turn()
		else: player_turn()
	else:
		remove_card(card)
		if opponent_cards.size() <= 0:
			return await win()
		if player_cards.size() <= 0:
			return await lose()
		if mode == Mode.OpponentTurn: opponent_turn()
		else: player_turn()

func remove_card(card: CardControl):
	opponent_cards.erase(card)
	player_cards.erase(card)
	card.set_visible(false)
	
