extends "res://Scripts/GameEntities/Items/Inventory Items/Inventory_Item.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	object_id_string = "Item_Name"

func get_item_info() -> Dictionary:
	return {
		ranged_damage_value: 10,
		ranged_damge_type: "bashing",
		melee_damage_value: 10,
		melee_damage_type: "stabbing"
	}
