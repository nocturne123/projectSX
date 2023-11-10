extends Control
class_name CardContainer

@onready var hand_card : W_HandCardContainer = %hand_card
@onready var draw_deck : W_Deck = %draw_deck
@onready var discard_deck : W_Deck = %discard_deck
@onready var arrow :Node2D = $bessel_arrow

var card_remove_index := 0

var _controller : C_CardSystem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	_controller = GameInstance.player.get_component("C_CardSystem")
##	card_preview.pivot_offset = Vector2(card_preview.size.x/2,card_preview.size.y)
##	card_preview.hide()
#	_controller.card_distributed.connect(
#		func(cards: Array) -> void:
#			draw_card(cards)
#	)
	EventBus.subscribe("card_distributed", _on_card_distributed)

## 抽卡
func draw_card(card: Card) -> void:
	hand_card.add_card(card)
	card.global_position = draw_deck.global_position

func _on_card_distributed(cards: Array) -> void:
	for card in cards:
		draw_card(card)
