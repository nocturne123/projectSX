extends Control
class_name W_CardManager

@onready var draw_deck : W_Deck = %draw_deck
@onready var discard_deck : W_Deck = %discard_deck
@onready var bezier_arrow : Node2D = %bezier_arrow
#@onready var w_card_list: Control = %w_card_list
@onready var w_hand_card: Control = %W_HandCard

var drag_card: W_Card = null:
	set(value):
		drag_card = value
		if drag_card != null:
			drag_card.scale = Vector2.ONE * 1.3
			drag_card.rotation = 0
			drag_card.z_index = 128
		else:
			#w_hand_card.update_card_layout()
			bezier_arrow.hide()
var drag_position : Vector2

## 战斗场景引用
#var _combat_scene : CombatScene 
## 卡牌管理器的引用
var _card_system : C_CardSystem

# combat_scene需要获取这个事件禁用下回合按钮
signal card_selected(card: Card)
signal card_unselected(card: Card)

func _ready() -> void:
	_card_system = GameInstance.player.get_node("C_CardSystem")
	#_combat_scene = SceneManager.current_scene
	_card_system.card_drawn.connect(_on_card_drawn)
	_card_system.card_released.connect(_on_card_released)
	_card_system.card_discarded.connect(_on_card_discarded)
	draw_deck.pressed.connect(_on_deck_pressed.bind(draw_deck))
	discard_deck.pressed.connect(_on_deck_pressed.bind(discard_deck))
	_card_system.draw_deck_replenished.connect(
		func():
			draw_deck.update_display()
			discard_deck.update_display()
	)
	_card_system.selected_cha_changed.connect(
		func(cha: Character) -> void:
			if cha:
				bezier_arrow.highlight()
			else:
				bezier_arrow.unhighlight()
	)

func _unhandled_input(event: InputEvent) -> void:
	if not drag_card or not drag_card.can_drag(): return
	if event is InputEventMouseMotion:
		if drag_card.needs_target():
			found_target()
		else:
			drag_card.global_position = event.global_position
	if event is InputEventMouseButton :
		if event.button_index == MOUSE_BUTTON_LEFT:
			# 此时如果是选择目标状态，则选择目标
			if can_release_card(drag_card):
				release_card(drag_card)
				#target_selector = null
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			# 此时是选择目标状态，则退出选择状态
			_cancel_card_drag()

## 取消拖拽卡牌
func _cancel_card_drag() -> void:
	drag_card = null
	w_hand_card.reset_layout()
	bezier_arrow.hide()
	#target_selector = null
	## TODO 调用card_system取消释放方法
	_card_system.target_selector = null
	_card_system.selected_cha = null

## 能否释放卡牌
func can_release_card(w_card: W_Card) -> bool:
	# 判断鼠标位置是否在屏幕下方（手牌区域）
	return _card_system.can_release_card(w_card.card)

## 释放卡牌
func release_card(w_card: W_Card) -> void:
	var card = w_card.card
	_card_system.release_card(card)
	drag_card = null
	bezier_arrow.hide()

## 寻找目标
func found_target() -> void:
	if not drag_card: return
	drag_card.global_position = w_hand_card.global_position + Vector2(drag_card.size.x/2 * -1, drag_card.size.y * -1)
	drag_card.rotation = 0
	drag_card.z_index = 128
	bezier_arrow.reset(drag_card.global_position+ Vector2(drag_card.size.x/2, drag_card.size.y/2), get_global_mouse_position())

## 创建卡牌控件
static func create_card_widget(card: Card) -> W_Card:
	var w_card : W_Card = preload("res://source/UI/widgets/card/w_card.tscn").instantiate()
	w_card.card = card
	return w_card

## 抽牌时候的表现效果处理
func _on_card_drawn(card: Card) -> void:
	var w_card : W_Card = create_card_widget(card)
	w_hand_card.add_child(w_card)
	w_card.drag_started.connect(_on_w_card_drag_started.bind(w_card))

## 卡牌释放的信号处理
func _on_card_released(card: Card) -> void:
	bezier_arrow.hide()
	#var w_card = w_hand_card.get_card(card)
	#w_hand_card.remove_child(w_card)
	_on_card_discarded(card)

## 卡牌被丢弃时候的信号处理
func _on_card_discarded(card: Card) -> void:
	var w_card = w_hand_card.get_card(card)
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.tween_property(w_card, "global_position", discard_deck.global_position, 0.3)
	tween.tween_property(w_card, "scale", Vector2.ZERO, 0.3)
	await tween.finished
	w_hand_card.remove_child(w_card)

## 点击牌堆时候的信号处理
func _on_deck_pressed(w_deck: W_Deck) -> void:
	#print("_on_deck_pressed", w_deck)
	if w_deck.card_amount <= 0:
		## TODO 玩家头顶冒泡提示
		print("当前牌堆没有卡牌！", w_deck)
		return
	%w_deck_details.w_deck = w_deck
	%w_deck_details.show()

## 卡牌开始拖拽
func _on_w_card_drag_started(at_position : Vector2, w_card: W_Card) -> void:
	print("_on_w_card_drag_started:", w_card, at_position)
	if not w_card.card.can_release(): return
	drag_position = at_position
	drag_card = w_card
	_card_system.prerelease_card(w_card.card)
	w_card.cancel_preview()