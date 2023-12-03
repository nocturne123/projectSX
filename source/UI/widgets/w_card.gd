extends Control
class_name W_Card

enum CARD_STATE {
	NORMAL, 
	DRAGGING, 
	PREVIEW,
	PRERELEASE, 
	}

@onready var lab_name: Label = %lab_name
@onready var tr_icon: TextureRect = %tr_icon
@onready var lab_description: RichTextLabel = %lab_description
@onready var lab_type: Label = %lab_type
@onready var lab_cost: Label = %lab_cost
@onready var t_card : TextureRect = $t_card

@export var card_state : CARD_STATE = CARD_STATE.NORMAL
@export var tween_speed : float = 0.1
@export var is_back : bool

@onready var timer_preview = $timer_preview
@onready var timer_release = $timer_release

var card : Card
var _model: CardModel:
	get:
		if not card:
			return null
		return card._model

signal drag_started

func _init() -> void:
	self.pivot_offset = Vector2(size.x/2, size.y)

func _ready():
#	self.pivot_offset = Vector2(card.size.x/2, card.size.y)
	lab_name.text = _model.card_name
	lab_description.text = _model.card_description
	lab_type.text = Card.CARD_TYPE_NAME[_model.card_type]
	lab_cost.text = str(_model.cost)
	tr_icon.texture = _model.icon

func get_offset_x() -> float:
	return $MarginContainer3.size.x

## 是否需要目标
func needs_target() -> bool:
	return card.needs_target()

## 当前能否拖动
func can_drag() -> bool:
	return card.can_release()

func _get_drag_data(at_position: Vector2) -> Variant:
	print(at_position)
	drag_started.emit(at_position)
	return null

func _to_string() -> String:
	return self.name + " : " + _model.card_name
