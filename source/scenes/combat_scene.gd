extends SceneBase
class_name CombatScene

@onready var combat_scene_controller: Node = %CombatSceneController

## 对于Controller层的引用
@onready var markers: Array = [
	%Marker2D1, # 玩家位置
	%Marker2D2, # 预留1
	%Marker2D3, # 预留2
	%Marker2D4, # 怪物1
	%Marker2D5, # 怪物2
	%Marker2D6, # 怪物3
]

@onready var combat_form: Control = $CanvasLayer2/combat_form
var characters : Array = []
var current_character: Character = null
var cha_selected: Character = null

## 进入当前场景，开始战斗
func _enter(msg:Dictionary = {}) -> void:
	if not "combat_id" in msg:
		push_error("combatScene初始化失败，没找到combat_id")
		return
	var combat_id = msg.combat_id
	
	init_combat(combat_id)

## 初始化战斗
func init_combat(combat_id : StringName) -> void:
	var data: Dictionary = DatatableManager.get_datatable_row("combat", combat_id)
	_init_player()
	_create_enemy(data.mark_04, 3)
	_create_enemy(data.mark_05, 4)
	_create_enemy(data.mark_06, 5)
	begin_combat()

## 开始战斗，战斗初始化
func begin_combat() -> void:
	await get_tree().create_timer(0.5).timeout
	for cha in characters:
		cha.mouse_entered.connect(_on_cha_mouse_entered.bind(cha))
		cha.mouse_exited.connect(_on_cha_mouse_exited.bind(cha))
		cha._begin_combat()
	next_turn()

## 开始回合
func next_turn() -> void:
	if current_character:
		current_character._end_turn()
		current_character = _get_next_character()
	else:
		current_character = characters[0]
	if current_character:
		current_character._begin_turn()

## 结束战斗
func end_combat() -> void:
	for cha in characters:
		cha.mouse_entered.disconnect(_on_cha_mouse_entered.bind(cha))
		cha.mouse_exited.disconnect(_on_cha_mouse_exited.bind(cha))
		cha._end_combat()

## 初始化玩家角色
func _init_player() -> void:
	var player : Character = GameInstance.player
	player.get_parent().remove_child(player)
	markers[0].add_child(GameInstance.player)
	characters.append(player)
	
## 创建敌人
func _create_enemy(enemyID: StringName, markerID: int) -> void:
	if enemyID.is_empty():
		return
	var enemy : Character = GameInstance.create_entity(AssetUtility.get_entity_path("enemy"))
	enemy.cha_id = enemyID
	markers[markerID].add_child(enemy)
	characters.append(enemy)

func _get_next_character() -> Character:
	if not current_character: return characters[0]
	for i in characters.size():
		if current_character == characters[i]:
			if i >= characters.size() - 1:
				return characters[0]
			else:
				return characters[i + 1]
	return characters[0]

func _on_cha_mouse_entered(cha: Character) -> void:
	cha_selected = cha

func _on_cha_mouse_exited(cha: Character) -> void:
	if cha_selected == cha:
		cha_selected = null
