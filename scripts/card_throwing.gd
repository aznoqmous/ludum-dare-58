class_name CardThrowing extends MiniGame

@onready var container: Control = $Container
@onready var background: TextureRect = $Container/Background
@onready var target: TextureRect = $Container/Target
@onready var shadow: TextureRect = $Container/Control/Shadow
@onready var arrow: TextureRect = $Container/Control/Arrow

@onready var player_card_node: Node2D = $Container/Control/PlayerCardNode
@onready var opponent_card_node: Node2D = $Container/Control/OpponentCardNode

var mode : Mode = Mode.OpponentTurn
enum Mode {
	OpponentTurn,
	Rotation,
	Distance,
	Throwing
}

func on_start():
	mode = Mode.OpponentTurn
	
	player_card_node.global_position = shadow.global_position
	opponent_card_node.global_position = shadow.global_position
	
	var alea = (lerp(200.0, 100.0, main.difficulty) +  randf_range(0, lerp(200.0, 100.0, main.difficulty)))
	var target_position = target.global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * alea
	await throw_card(opponent_card_node, target_position)
	mode = Mode.Rotation

var current_rotation = 0.0
var current_distance = 0.0

func _process(delta):
	match mode:
		Mode.Rotation:
			var max = PI * 0.2
			arrow.rotation = sin(main.get_time() * TAU / 4.0) * max
			current_rotation = abs(arrow.rotation) / max
			arrow.modulate = lerp(Color.GREEN_YELLOW, Color.RED, current_rotation)
		Mode.Distance:
			var max = 0.2
			arrow.scale.x = 1.0 + sin(main.get_time() * TAU / 4.0) * max
			current_distance = abs(1.0 - arrow.scale.x) / max
			arrow.modulate = lerp(Color.GREEN_YELLOW, Color.RED, current_distance)
		Mode.Throwing:
			#player_card_control.rotation += delta * 10.0
			pass

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1:
		if mode == Mode.Rotation and event.is_pressed():
			mode = Mode.Distance
		if mode == Mode.Distance and event.is_released():
			mode = Mode.Throwing
			var target_position = target.global_position + Vector2(current_distance, -current_rotation) * 400.0
			await throw_card(player_card_node, target_position)
			
			if player_card_node.global_position.distance_to(target.global_position) <= opponent_card_node.global_position.distance_to(target.global_position):
				win()
			else:
				lose()
			
func throw_card(card, target_position):
	get_tree().create_tween().tween_property(card, "global_position", target_position, 1.0)
	get_tree().create_tween().tween_property(card, "rotation", randf_range(TAU, TAU * 5.0), 1.0)	
	await get_tree().create_timer(1.0).timeout
