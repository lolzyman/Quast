extends CenterContainer
class_name Inventory_User_Interface

#Expected Inventory Dictionary Format
#Inventory: Dictionary
#{
#	Key: Int
#	Value: Dictionary
#	{
#		Key:"Item"
#		Value:Object - Item Packed Scene
#		
#		Key:"Quantity"
#		Value:Int
#		
#		Key:"Max_Quantity"
#		Value: Int
#	}
#}

signal head_equipment_changed(new_item, old_item);
signal torso_equipment_changed(new_item, old_item);
signal left_hand_quipment_changed(new_item, old_item);
signal right_hand_equipment_changed(new_item, old_item);
signal leg_equipment_changed(new_item, old_item);
signal feet_equipment_changed(new_item, old_item);

export (PackedScene) var inventory_slot;
export (Dictionary) var dummyDictionary;
var monitoring_dictionary = {}
var my_source_dictionary;
func _ready():
	add_grid_spaces(20);
	prep_from_dictionary(dummyDictionary);
	connect("head_equipment_changed", self ,"dummy_emitter")
	my_source_dictionary = dummyDictionary;

func add_grid_spaces(space_count : int):
	for index in range(space_count):
		var new_inventory_slot = inventory_slot.instance();
		$"Window Spacer/CenterContainer/Inventory/Grid Spacing".add_child(new_inventory_slot);
		new_inventory_slot.connect("item_change", self, "inventory_movement_handler");
		new_inventory_slot.new_parent = self;

func update_inventory():
	print("I got called")
	prep_from_dictionary(my_source_dictionary);

func inventory_movement_handler(moving_item_slot:Item_Element_Class, stationary_item_slot:Item_Element_Class):
	var moving_has_item = !moving_item_slot.is_empty();
	var stationary_has_item = !stationary_item_slot.is_empty();
	var moving_item_slot_key = moving_item_slot.my_item_dictionary;
	var stationary_item_slot_key = stationary_item_slot.my_item_dictionary;
	if moving_has_item:
		if stationary_has_item:
			moving_item_slot.update_item(stationary_item_slot_key);
			stationary_item_slot.update_item(moving_item_slot_key);
			monitoring_dictionary[moving_item_slot_key] = stationary_item_slot;
			monitoring_dictionary[stationary_item_slot_key] = moving_item_slot
		else:
			moving_item_slot.clear();
			stationary_item_slot.update_item(moving_item_slot_key);
			monitoring_dictionary[moving_item_slot_key] = stationary_item_slot;
	if stationary_item_slot.my_function == Item_Element_Class.function_type.equipment_slot:
		handle_equipment_movement(stationary_item_slot.my_equipment_function, moving_item_slot_key, stationary_item_slot_key);
	if moving_item_slot.my_function == Item_Element_Class.function_type.equipment_slot:
		handle_equipment_movement(moving_item_slot.my_equipment_function, stationary_item_slot_key, moving_item_slot_key);
	

func prep_from_dictionary(source_dictionary : Dictionary):
	for item_key in source_dictionary:
		var item = source_dictionary[item_key];
		print("prep_from_dictionary starting", item);
		if validate_item_dictionary(item):
			if monitoring_dictionary.has(item["Key"]):
				#Update Item
				monitoring_dictionary[item["Key"]].update_item(item);
				pass
			else:
				#Create new Item
				var new_slot = next_available_inventory_space();
				if new_slot == null:
					print("There is an error. The inventory should be full", "Inventory_Overlay.gd", "prep_from_dictionary");
				else:
					monitoring_dictionary[item["Key"]] = new_slot;
					new_slot.update_item(item);
		else:
			print("There is a imporperly congiure item dictionary!");

func handle_equipment_movement(equipment_slot_id, new_item, old_item):
	match(equipment_slot_id):
			Item_Element_Class.equipment_slot_type.head:
				emit_signal("head_equipment_changed", new_item, old_item)
			Item_Element_Class.equipment_slot_type.left_hand:
				emit_signal("left_hand_equipment_changed", new_item, old_item)
			Item_Element_Class.equipment_slot_type.right_hand:
				emit_signal("right_hand_equipment_changed", new_item, old_item)
			Item_Element_Class.equipment_slot_type.torso:
				emit_signal("torso_equipment_changed", new_item, old_item)
			Item_Element_Class.equipment_slot_type.legs:
				emit_signal("legs_equipment_changed", new_item, old_item)
			Item_Element_Class.equipment_slot_type.feet:
				emit_signal("feet_equipment_changed", new_item, old_item)

func dummy_emitter(new_item, old_item):
	print("Signal Emiited");

func next_available_inventory_space() -> Node:
	var monitoring_dictionary_values = monitoring_dictionary.values();
	for child in $"Window Spacer/CenterContainer/Inventory/Grid Spacing".get_children():
		if !monitoring_dictionary_values.has(child):
			return child
	return null

func validate_item_dictionary(item_dictionary: Dictionary) -> bool:
	if item_dictionary.has_all(["Item", "Quantity", "Max_Quantity","Key"]):
		return true;
	return false

func set_inventory_view(new_state:bool):
	$"Window Spacer/CenterContainer".visible = new_state;

func toggle_view():
	visible = !visible;
	
func set_character_equipment(new_state:bool):
	$"Window Spacer/Armor Equipment".visible = new_state;

func set_item_equipment(new_state:bool):
	$"Window Spacer/Item Equipment".visible = new_state;
