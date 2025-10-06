class_name CardBattle extends MiniGame

@onready var player_cards_container: HBoxContainer = $Container/PlayerCards/PlayerCardsContainer
@onready var opponent_cards_container: HBoxContainer = $Container/OpponentCards/OpponentCardsContainer
@export var opponent_cards: Array[CardControl]
@export var player_cards: Array[CardControl]
@onready var center: Control = $Container/Center

var center_card : CardControl

var is_center_player_card : bool : 
	get: return player_cards.has(center_card)

var mode: Mode = Mode.OpponentTurn

enum Mode {
	PlayerTurn,
	OpponentTurn
}

func on_start():
	opponent_cards.shuffle()
	var random_cards = main.pick_cards(2)
	opponent_cards[0].load_card_resource(random_cards[0])
	opponent_cards[1].load_card_resource(random_cards[1])
	opponent_cards[2].load_card_resource(opponent_card)
	
	for card in opponent_cards:
		card.set_unknown(true)
	
	player_cards.shuffle()
	player_cards[0].load_card_resource(main.player_collection.cards.pick_random())
	player_cards[1].load_card_resource(main.player_collection.cards.pick_random())
	player_cards[2].load_card_resource(player_card)
	
	for card in player_cards:
		card.click.connect(func():
			play_card(card)
		)
	
	await main.wait(0.5)
	opponent_turn()

func opponent_turn():
	mode = Mode.OpponentTurn
	play_card(opponent_cards.pick_random())

func player_turn():
	mode = Mode.PlayerTurn
	
func play_card(card: Control):
	card.z_index = 1.0
	get_tree().create_tween().tween_property(
		card, "global_position", 
		center.global_position - card.size / 2.0 + Vector2.RIGHT.rotated(randf_range(0.0, TAU) * randf_range(20.0, 200.0)), 
		0.5
	)
	card.set_unknown(false)
	await main.wait(0.5)
	
	if not center_card:
		center_card = card
		card.z_index = 0.0
		mode = Mode.PlayerTurn if mode == Mode.OpponentTurn else Mode.OpponentTurn
		return
	
	if center_card.card_resource.power <= card.card_resource.power or center_card.card_resource.color == card.card_resource.color:
		remove_card(center_card)
		center_card = card
		card.z_index = 0.0
		if mode == Mode.PlayerTurn: opponent_turn()
		else: player_turn()
	else:
		remove_card(card)
		if mode == Mode.OpponentTurn: opponent_turn()
		else: player_turn()
		
	if opponent_cards.size() <= 0: win()
	if player_cards.size() <= 0: lose()

func remove_card(card: CardControl):
	opponent_cards.erase(card)
	player_cards.erase(card)
	card.get_parent().remove_child(card)
	card.queue_free()
	
