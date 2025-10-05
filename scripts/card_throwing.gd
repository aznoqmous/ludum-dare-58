class_name CardThrowing extends MiniGame

@onready var container: Control = $Container
@onready var background: TextureRect = $Container/Background
@onready var target: TextureRect = $Container/Target
@onready var shadow: TextureRect = $Container/Control/Shadow
@onready var arrow: TextureRect = $Container/Control/Arrow
@onready var control: Control = $Container/Control

@onready var player_card_node: CardNode = $Container/Control/PlayerCardNode
@onready var opponent_card_node: CardNode = $Container/Control/OpponentCardNode

var mode : Mode = Mode.OpponentTurn
enum Mode {
	OpponentTurn,
	Rotation,
	Distance,
	Throwing
}

var max_distance
var max_angle = PI * 0.05

func on_start():
	mode = Mode.OpponentTurn
	
	player_card_node.global_position = shadow.global_position
	opponent_card_node.global_position = shadow.global_position

	player_card_node.load_card_resource(player_card)
	opponent_card_node.load_card_resource(opponent_card)
	
	max_distance = target.global_position.distance_to(control.global_position)
	
	var alea_distance = lerp(0.6, 1.0, main.difficulty) * max_distance
	var alea_angle = lerp(1.0, 0.0, main.difficulty) * max_angle * (-1.0 if randf() > 0.5 else 1.0)
	var target_position = control.global_position + Vector2.RIGHT.rotated(alea_angle) * alea_distance
	await throw_card(opponent_card_node, target_position)
	mode = Mode.Rotation

var current_rotation = 0.0
var current_distance = 0.0

func _process(delta):
	var value = sin(main.get_time() * TAU / 4.0 + PI)
	match mode:
		Mode.Rotation:
			arrow.rotation = value * max_angle * 2.0
			current_rotation = arrow.rotation * 0.5
			arrow.modulate = lerp(Color.GREEN_YELLOW, Color.RED, abs(current_rotation) / max_angle)
			
		Mode.Distance:
			var max = 0.2
			arrow.scale.x = 1.0 + value * max
			current_distance = abs(1.0 - arrow.scale.x) / max
			arrow.modulate = lerp(Color.GREEN_YELLOW, Color.RED, current_distance)
			current_distance = lerp(max_distance, 100.0, abs(value))
			
		Mode.Throwing:
			#player_card_control.rotation += delta * 10.0
			pass

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1:
		if mode == Mode.Rotation and event.is_pressed():
			mode = Mode.Distance
		if mode == Mode.Distance and event.is_released():
			mode = Mode.Throwing
			var target_position = control.global_position + Vector2.RIGHT.rotated(current_rotation) * current_distance
			await throw_card(player_card_node, target_position)
			
			if player_card_node.global_position.x >= opponent_card_node.global_position.x:
				win()
			else:
				lose()
			
func throw_card(card: CardNode, target_position):
	get_tree().create_tween().tween_property(card, "global_position", target_position, 1.0)
	get_tree().create_tween().tween_property(card, "rotation", randf_range(TAU * 2.0, TAU * 6.0), 1.0).as_relative()
	await main.wait(1.0)
	card.impact_particles.emitting = true
	await main.wait(1.0)
