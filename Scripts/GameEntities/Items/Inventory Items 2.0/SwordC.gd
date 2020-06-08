extends Sprite


export (PackedScene) var attack_sprite;
export (PackedScene) var attack_collider;
var object_id_string = "Generic_Sword";

func get_item_info() -> Dictionary:
	return {
		"Melee_Damage_Value": 50,
		"Melee_Damage_Type": "slashing",
		"Attack_Sprite": attack_sprite,
		"Attack_Collider": attack_collider
	}
