extends Area2D
var inventory = {}
var managed_inventory:Managed_Inventory = Managed_Inventory.new();
var next_available_key = 0;
const generic_player = preload('res://Scripts/GameEntities/Characters/PlayerController.gd')

func _ready():
	add_to_group("Interactable")

func add_item_to_bag(item_dictionary:Dictionary):
	# This needs to be updated as soon as the new Inventory UI is created
	managed_inventory.add_item({"Item":item_dictionary["Item_Type"], "Quantity":item_dictionary["Quantity"], "Max_Quantity":20});
	inventory[next_available_key] = item_dictionary;
	next_available_key += 1;

func self_validate():
	if managed_inventory.inventory.empty():
		queue_free();

func add_item_array_to_bag(item_array:Array):
	for item in item_array:
		add_item_to_bag(item);

func addToItemList():
	print("Trying to add to script")
	globals.collect_Item(inventory);
	#queue_free();
	pass

func interact(calling_Entitiy:generic_player):
	var other_managed_inventory = calling_Entitiy.managed_inventory;
	other_managed_inventory.add_item_array(managed_inventory.get_all_items());
	queue_free();
