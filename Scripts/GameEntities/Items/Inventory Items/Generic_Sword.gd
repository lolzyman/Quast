extends "res://Scripts/GameEntities/Items/Inventory Items/Inventory_Item.gd"

export (PackedScene) var attack_sprite;
export (PackedScene) var attack_collider
func _ready():
	object_id_string = "Generic_Sword"

func get_item_info() -> Dictionary:
	return {
		"Melee_Damage_Value": 10,
		"Melee_Damage_Type": "slashing",
		"Attack_Sprite": attack_sprite,
		"Attack_Collider": attack_collider
	}
