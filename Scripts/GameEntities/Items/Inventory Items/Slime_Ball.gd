extends "res://Scripts/GameEntities/Items/Inventory Items/Inventory_Item.gd"

export (PackedScene) var my_projectile_type;
func _ready():
	object_id_string = "Slime_Ball"

func get_projectile():
	return my_projectile_type;

func get_item_info() -> Dictionary:
	return {
		ranged_damage_value = 10,
		ranged_damge_type = "blunt"
	}
