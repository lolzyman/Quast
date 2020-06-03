extends Node

class_name Managed_Inventory

var inventory:Dictionary;
var max_size = 10;
var next_index = 0;
var free_indecies = [];

func _ready():
	inventory = {};

func remove_item_by_value(item_dictionary:Dictionary):
	if !item_dictionary.has_all(["Item", "Quantity", "Max_Quantity"]):
		print("Item Dictionary isn't formated correctly");
	for key in inventory.keys():
		if inventory[key].hash() == item_dictionary.hash():
			remove_item_by_key(key);

func remove_item_by_key(item_key):
	if inventory.has(item_key):
		if item_key != next_index - 1:
			free_indecies.push_back(item_key);
		else:
			next_index -= 1;
		var _return_value = inventory.erase(item_key);

func update():
	remove_empty_items();

func remove_empty_items():
	for key in inventory.keys():
		if inventory[key]["Quantity"] == 0:
			remove_item_by_key(key);

func add_item(item_dictionary) -> bool:
	#Dictionary Format Check
	if !item_dictionary.has_all(["Item", "Quantity", "Max_Quantity"]):
		print("Item Dictionary isn't formated correctly");
		return false;
	
	#Combine with exsisting item
	for key in inventory.keys():
		if inventory[key]["Item"] == item_dictionary["Item"]:
			var available_space = inventory[key]["Max_Quantity"] - inventory[key]["Quantity"];
			if item_dictionary["Quantity"] < available_space:
				inventory[key]["Quantity"] += item_dictionary["Quantity"];
				return true;
			if available_space > 0:
				inventory[key]["Quantity"] += available_space;
				item_dictionary["Quantity"] -= available_space;
				return true;
	
	#Place in empty slot
	if !free_indecies.empty():
		inventory[free_indecies.pop_back()] = item_dictionary;
		return true;
	if next_index < max_size:
		inventory[next_index] = item_dictionary;
		next_index += 1;
		return true;
	return false;

func add_item_array(item_array:Array) -> Array:
	var rejected_items = [];
	for item in item_array:
		if !add_item(item):
			rejected_items.push_back(item);
	return rejected_items;

func get_all_items() -> Array:
	var return_array = [];
	for key in inventory.keys():
		return_array.push_back(inventory[key]);
	return return_array;

func sort_inventory():
	# Pending update
	pass
