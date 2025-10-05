class_name CardShuffle extends MiniGame

@onready var cards_container: Control = $Control/CardsContainer
@export var cards : Array[CardControl]
var mode : Mode = Mode.Shuffle

var _speed = 0.5

enum Mode {
	Shuffle,
	PlayerChoice,
	Reveal
}

func on_start():
	last_picks.clear()

	var children = cards.duplicate()
	children.shuffle()
	children[0].load_card_resource(opponent_card)
	children[1].load_card_resource(player_card)
	children[2].load_card_resource(player_card)
	
	children[0].shuffle_win_card = true
	children[1].shuffle_win_card = false
	children[2].shuffle_win_card = false
	
	for c in cards: c.set_unknown(true)
	children[0].set_unknown(false)
	
	await main.wait(1.0)
	
	for c in cards: c.set_unknown(true)
	
	for i in range(0, 3):
		await rand_swap()
	
	mode = Mode.PlayerChoice
	
	for pcard in cards:
		pcard.click.connect(func():
			if mode != Mode.PlayerChoice: return
			mode = Mode.Reveal
			
			pcard.set_unknown(false)
			
			await main.wait(1.0)
			if pcard.shuffle_win_card: win()
			else: lose()
		)

var last_picks : Array[CardControl] = []

func rand_swap():
	var a = cards.pick_random()
	if last_picks:
		var ccards = cards.duplicate()
		ccards.erase(last_picks[0])
		ccards.erase(last_picks[1])
		a = ccards[0]
		
	var b = cards.filter(func(c): return a != c).pick_random()
	await swap(a,b)
	last_picks = [a, b]
	
func swap(a, b):
	var speed = _speed * lerp(1.0, 0.5, main.difficulty)
	var middle = (a.global_position.x + b.global_position.x) / 2.0
	var aPosition = a.global_position
	var bPosition = b.global_position
	get_tree().create_tween().set_trans(Tween.TRANS_SINE).tween_property(a, "global_position:x", middle, speed)
	get_tree().create_tween().set_trans(Tween.TRANS_SINE).tween_property(b, "global_position:x", middle, speed)
	get_tree().create_tween().set_trans(Tween.TRANS_SINE).tween_property(a, "global_position:y", a.global_position.y + 50.0, speed)
	get_tree().create_tween().set_trans(Tween.TRANS_SINE).tween_property(b, "global_position:y", b.global_position.y - 50.0, speed)
	
	await main.wait(speed)
	get_tree().create_tween().set_trans(Tween.TRANS_SINE).tween_property(a, "global_position", bPosition, speed)
	get_tree().create_tween().set_trans(Tween.TRANS_SINE).tween_property(b, "global_position", aPosition, speed)
	
	await main.wait(speed)
	
