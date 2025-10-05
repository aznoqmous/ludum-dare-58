class_name Dealer extends Child

var card_count : int :
	get: return (main.difficulty) * 2 + 1
	
var battle_count = 1
var battle_until_refill : int = 3

func start():
	main.difficulty_changed.connect(func(): pick_cards())
	main.mini_game_ended.connect(func(mini_game: MiniGame):
		battle_count += 1
		if battle_count >= battle_until_refill:
			pick_cards()
			battle_count = 0
	)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1 and hovered:
		if cards.size():
			main.card_selection.open(self, true)
			hide_bubble()
		else:
			set_bubble(main.emoji_cross, 1.0)
			
func pick_cards():
	var cs = main.cards.duplicate()
	cs.shuffle()
	cards = cs.slice(0, card_count)
	set_bubble(main.emoji_exclamation)
