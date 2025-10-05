class_name CardSelection extends CanvasLayer

@onready var main : Main = $"/root/Main"

@onready var card_selection_control: VBoxContainer = $Panel/CardSelectionControl
@onready var opponent_cards_container: HBoxContainer = $Panel/CardSelectionControl/OpponentCards
@onready var player_cards_container: HBoxContainer = $Panel/CardSelectionControl/ScrollContainer/PlayerCards
@onready var return_button: CustomButton = $Panel/ReturnButton

@onready var shop_button: Control = $Panel/ShopButton
@onready var pre_minigame_button: Control = $Panel/PreMinigameButton
@onready var shop_pick_card_button: CustomButton = $Panel/ShopButton/PickCardButton
@onready var pre_mini_game_pick_card_button: CustomButton = $Panel/PreMinigameButton/PickCardButton

@onready var character_texture: TextureRect = $Panel/Character/CharacterTexture
@onready var bubble: TextureRect = $Panel/Character/Bubble
@onready var emoji: TextureRect = $Panel/Character/Bubble/Emoji

@onready var dealer_label: Label = $Panel/CardSelectionControl/DealerLabel
@onready var battle_label: Label = $Panel/CardSelectionControl/BattleLabel

var pick_card_button: CustomButton

var opponent : Child
var opponent_cards : Array[CardControl] = []
var player_cards : Array[CardControl] = []

var selected_player_card : CardControl
var selected_opponent_card : CardControl

var shop_selected_player_cards : Array[CardControl]
var shop_selected_dealer_cards : Array[CardControl]

var shop_player_score : float = 0.0
var shop_dealer_score : float = 0.0

func _ready():
	
	pre_mini_game_pick_card_button.pressed.connect(func():
		if selected_opponent_card and selected_player_card:
			var mini_game : MiniGame = main.mini_games.pick_random()
			main.start_mini_game(mini_game, selected_player_card.card_resource, selected_opponent_card.card_resource, opponent)
			set_visible(false)
	)
	
	shop_pick_card_button.pressed.connect(func():
		if shop_selected_dealer_cards.size() > 0.0 and shop_selected_player_cards.size() > 0.0:
			for card in shop_selected_player_cards:
				main.player_collection.remove_card(card.card_resource)
				
			for card in shop_selected_dealer_cards:
				main.player_collection.add_card(card.card_resource)
				opponent.cards.erase(card.card_resource)
				opponent_cards.erase(card)
				opponent_cards_container.remove_child(card)
				await main.wait(0.5)
				
			if not opponent_cards.size() : set_visible(false)
			else: 
				update_player_cards()
	)
	return_button.pressed.connect(func():
		set_visible(false)
	)

var _is_shop := false
func open(child : Child, is_shop := false):
	
	character_texture.texture = child.sprite_2d.texture
	
	_is_shop = is_shop
	bubble.set_visible(_is_shop)
	emoji.texture = main.emoji_ok_texture
	pick_card_button = shop_pick_card_button if _is_shop else pre_mini_game_pick_card_button
	pre_minigame_button.set_visible(not _is_shop)
	shop_button.set_visible(_is_shop)
	battle_label.set_visible(not _is_shop)
	dealer_label.set_visible(_is_shop)
	
	selected_player_card = null
	selected_opponent_card = null
	shop_selected_player_cards.clear()
	shop_selected_dealer_cards.clear()
	
	opponent = child
	
	update_opponent_cards()
	update_player_cards()
	
	set_visible(true)
	
	update_button()

func update_opponent_cards():
	for card in opponent_cards_container.get_children():
		opponent_cards_container.remove_child(card)
	opponent_cards.clear()
	for card_resource in opponent.cards:
		var card = main.create_card_control(card_resource, opponent_cards_container)
		bind_opponent_card(card)
		opponent_cards.append(card)
		card.unselect()
		
func update_player_cards():
	for card in player_cards_container.get_children():
		player_cards_container.remove_child(card)
		
	player_cards.clear()
	for card_resource in main.player_collection.cards:
		var card = main.create_card_control(card_resource, player_cards_container)
		bind_player_card(card)
		player_cards.append(card)
		card.unselect()

func bind_opponent_card(card: CardControl):
	card.click.connect(func():
		var state = not card.selected
		opponent_cards.map(func(oc: CardControl): oc.unselect())
		if state:
			if not _is_shop:
				player_cards.map(func(pc: CardControl):
					if card.card_resource.card_rarity > pc.card_resource.card_rarity:
						pc.disable()
						pc.unselect()
					else: pc.enable()
				)
				if selected_player_card and card.card_resource.card_rarity > selected_player_card.card_resource.card_rarity:
					selected_player_card = null
			card.select()
			shop_selected_dealer_cards = [card]
			selected_opponent_card = card
		else:
			if not _is_shop:
				player_cards.map(func(pc: CardControl): pc.enable())
			shop_selected_dealer_cards.clear()
			selected_opponent_card = null
			card.unselect()
		update_button()
	)

func bind_player_card(card: CardControl):
	card.click.connect(func():
		var state = not card.selected
		if not _is_shop: player_cards.map(func(card: CardControl): card.unselect())
		if state:
			shop_selected_player_cards.append(card)
			selected_player_card = card
			card.select()
		else: 
			shop_selected_player_cards.erase(card)
			selected_player_card = null
			card.unselect()
		update_button()
	)

var slider_value : float = 0.0
func update_button():
	pick_card_button.disabled = true
	if _is_shop:
		shop_player_score = 0.0
		shop_dealer_score = 0.0
		print(shop_selected_dealer_cards, shop_selected_player_cards)
		for card in shop_selected_dealer_cards:
			shop_dealer_score += pow(3, card.card_resource.card_rarity)
		for card in shop_selected_player_cards:
			shop_player_score += pow(3, card.card_resource.card_rarity)
		
		slider_value = sign(shop_player_score - shop_dealer_score)
		
		pick_card_button.text = "Chose cards to trade"
		
		
		if shop_dealer_score == 0:
			emoji.texture = main.emoji_ok_texture
			return
		elif slider_value < 0:
			emoji.texture = main.emoji_sad_texture
			return
		else:
			emoji.texture = main.emoji_happy_texture

	else:
		if not selected_opponent_card:
			pick_card_button.text = "Chose a card from your opponent"
			return;
		if not selected_player_card:
			pick_card_button.text = "Select one of your card"
			return;
	pick_card_button.disabled = false
	pick_card_button.text = "TRADE !" if _is_shop else "FIGHT !"
