extends Area2D
var inventory = {}
var next_available_key = 0;
const generic_player = preload('res://Scripts/GameEntities/Characters/PlayerController.gd')

func _ready():
	add_to_group("Interactable")

func add_item_to_bag(item_dictionary:Dictionary):
	inventory[next_available_key] = item_dictionary;
	next_available_key += 1;
func add_item_array_to_bag(item_array:Array):
	for item in item_array:
		add_item_to_bag(item);

func addToItemList():
	print("Trying to add to script")
	globals.collect_Item(inventory);
	#queue_free();
	pass

func interact(calling_Entitiy:generic_player):
	var other_inventory = calling_Entitiy.inventory;
	for key in inventory.keys():
		if other_inventory.keys().size() >= 30:
			print("Inventory Full")
			return
		var item_added = false
		for other_key in other_inventory.keys():
			var my_inventory_item = inventory[key];
			var other_inventory_item = other_inventory[other_key];
			if my_inventory_item["Item_Type"] == other_inventory_item["Item_Type"]:
				if my_inventory_item["Stackable"] && other_inventory_item["Stackable"]:
					other_inventory_item["Quantity"] += my_inventory_item["Quantity"];
					item_added = true;
					break;
		if !item_added:
			other_inventory[calling_Entitiy.inventory_next_key] = inventory[key]
			calling_Entitiy.inventory_next_key += 1;
		inventory.erase(key);
		calling_Entitiy.inventory_change_flag = true;
	queue_free()