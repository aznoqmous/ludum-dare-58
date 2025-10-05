class_name CardResource extends Resource

@export var name : String = "Card Name"
@export var texture : Texture
@export var power : int = 1
@export var card_color: CARD_COLOR = CARD_COLOR.BLUE
@export var card_rarity : CARD_RARITY = CARD_RARITY.COMMON
@export_multiline var description:String = ""

var color: Color :
	get: return CARD_COLORS[card_color]
var rarity_color: Color :
	get: return CARD_RARITY_COLORS[card_rarity]
	
enum CARD_COLOR {
	BLUE,
	GREEN,
	PINK,
	RED,
	YELLOW,
	PURPLE,
	ORANGE
}

var CARD_COLORS = [
	"#3aa5db",
	"#75d200",
	"#ff85a4",
	"#ff1515",
	"#ffcb29",
	"#da75e8",
	"#ff964d"
]

enum CARD_RARITY {
	COMMON,
	RARE,
	EPIC
}
var CARD_RARITY_COLORS = [
	"#dedede",
	"#4c4c4c",
	"#ffd221"
]
