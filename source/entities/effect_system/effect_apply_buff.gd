extends Effect
class_name EffectApplyBuff

var buff : StringName
## buff的层数或者数值
var value := 0

func _init(data: Dictionary, targets: Array) -> void:
	super(data, targets)
	buff = data.effect_parameters[0]
	value = int(data.effect_parameters[1])

func execute() -> void:
	if _targets.is_empty() : return
	for target in _targets:
		var c_buff_system : C_BuffSystem = target.get_node("C_BuffSystem")
		var buff = Buff.new(buff, value)
		c_buff_system.apply_buff(buff)
