class_name MiniGame extends CanvasLayer

@onready var main: Main = $"/root/Main"

var player_card : CardResource
var opponent_card : CardResource
var opponent : Child

func start(the_player_card: CardResource, the_opponent_card: CardResource, the_opponent: Child):
	player_card = the_player_card
	opponent_card = the_opponent_card
	opponent = the_opponent
	set_visible(true)
	on_start()
	main.mini_game_started.emit(self)
	
# to implement in subclasses
func on_start(): pass

func win():
	
	opponent.cards.erase(opponent_card)
	
	main.mini_game_win_screen.open()
	main.mini_game_win_screen.set_win()
	main.mini_game_win_screen.load_card(opponent_card)
	
	
	if not opponent.cards.size(): main.remove_children(opponent)
	
	set_visible(false)
	
	await main.wait(0.5)
	main.player_collection.add_card(opponent_card)
	main.mini_game_ended.emit(self)
	opponent.set_bubble(main.emoji_sad_texture, 1.0)
	
func lose():
	main.mini_game_win_screen.open()
	main.mini_game_win_screen.set_lose()
	main.mini_game_win_screen.load_card(player_card)
	
	main.player_collection.remove_card(player_card)
	set_visible(false)
	main.mini_game_ended.emit(self)
	opponent.set_bubble(main.emoji_happy_texture, 1.0)
