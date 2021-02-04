extends Resource
class_name Ability


export(String) var name
export(Array, int) var requirement


func _ready() -> void:
	self.requirement.sort()


func is_requirement_met( values: Array ) -> bool:
	values.sort()
	return values == self.requirement
