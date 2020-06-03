extends Control

#export (PackedScene) var item
var character_inventory
var character_equipment
var character
var ui_inventory_lookup = {}
var ui_equipment_lookup = {}
var FPS_Timer
var debug_chain := [Game_Constants]
var target_variable_parent = Game_Constants
var target_variable_name := ""
var suppress_change := false

func _ready():
	print("User Interface In!")
	globals.connect("_handle_Item_Collection", self, "add_item");
	FPS_Timer = Timer.new()
	FPS_Timer.connect("timeout", self, "update_fps_display")
	FPS_Timer.start(1);
	process_parameter_list()
	$CanvasLayer/Int_Changer.get_line_edit().connect("mouse_exited", self, "disable_focus")
	get_tree().get_root().connect("size_changed", self, "screen_resize")
	add_child(FPS_Timer)

func _physics_process(_delta):
	#process_parameter_list()
	pass

func update_fps_display():
	$CanvasLayer/FPS_Display.text = "FPS: " + str(Engine.get_frames_per_second());

func add_item(item_dictionary:Dictionary):
	var items = item_dictionary.keys();
	for item in items:
		var newItem = item.instance();
		for placeholder in $CanvasLayer/Inventory_Placeholders.get_children():
			if placeholder.accept_item(newItem):
				$CanvasLayer/Character_Inventory.add_child(newItem);
				return

func update_to_inventory(item, placeholder, change_code):
	# change_types
	# Item Combined
	# Item Split
	# Item Equipped
	# Item Unequipped
	# Item Moved
	# Item Interacted with
	match change_code:
		"Item_Equipping":
			character.equip(item, placeholder.accepted_keyword)
			update_from_inventory()
		"Item_Moving":
			print("Item_moved")
			update_inventory_from_ui()
			pass
		"Item_Unequipping":
			character.unequip(item)
			update_from_inventory()
			pass
	#print(item," ", change_code)
	pass

func remove_from_ui(item_information:Dictionary):
	print(item_information)
	if item_information["UI_Item_Nodepath"] != null:
		var UI_Item = get_node(item_information["UI_Item_Nodepath"]);
		UI_Item.queue_free();
	if item_information["UI_Placeholder_Nodepath"]:
		var UI_Item_Placeholder = get_node(item_information["UI_Placeholder_Nodepath"]);
		UI_Item_Placeholder.occupied = false;
		UI_Item_Placeholder.owned_item = null;
func place_item(item):
	var item_node = get_node(item["UI_Item_Nodepath"]);
	for placeholder in $CanvasLayer/Inventory_Placeholders.get_children():
		if !placeholder.occupied:
			item_node.position = placeholder.position;
			item_node.current_placeholder = placeholder;
			placeholder.occupied = true;
			placeholder.owned_item = item_node;
			item["UI_Placeholder_Nodepath"] = placeholder.get_path()
			return
func update_inventory_from_ui():
	for item in character_inventory.values():
		var item_node = get_node(item["UI_Item_Nodepath"]);
		if item_node == null:
			print("You got some problems here");
		item["UI_Placeholder_Nodepath"] = item_node.current_placeholder.get_path();
	pass
func update_from_inventory():
	for item_key in character_inventory.keys():
		var item = character_inventory[item_key];
		if item["UI_Item_Nodepath"] == null:
			var newItem = item["Item_Type"].instance();
			$CanvasLayer/Character_Inventory.add_child(newItem);
			item["UI_Item_Nodepath"] = newItem.get_path();
			newItem.source_dictionary = item;
		if item["UI_Placeholder_Nodepath"] == null:
			place_item(item);
		var item_node = get_node(item["UI_Item_Nodepath"])
		item_node.quantity = item["Quantity"]
		item_node.refresh();
	pass

## *****************************************************************
## Variable Debugger Methods
## *****************************************************************

func clear_list():
	while $CanvasLayer/Parameter_Lists.get_item_count() > 0:
		$CanvasLayer/Parameter_Lists.remove_item(0)

func process_parameter_list():
	var param_list = process_chain();
	var list = $CanvasLayer/Parameter_Lists
	for dict in param_list.get_property_list():
		if dict["usage"] == 8199:
			list.add_item(dict["name"]);
			var current_index = list.get_item_count() -1;
			match dict["type"]:
				TYPE_ARRAY:
					#list.set_item_custom_bg_color(current_index, Color(125,125,125))
					pass
				TYPE_INT:
					pass
				TYPE_STRING:
					pass
				TYPE_OBJECT:
					#list.set_item_custom_bg_color(current_index, Color(200,125,100))
					pass

func _on_Parameter_Lists_item_selected(index):
	var list = $CanvasLayer/Parameter_Lists
	var variable = target_variable_parent.get(list.get_item_text(index))
	print(typeof(variable))
	match typeof(variable):
		TYPE_REAL:
			continue
		TYPE_INT:
			target_variable_name = list.get_item_text(index)
			$CanvasLayer/Int_Changer.visible = true
			suppress_change = true
			$CanvasLayer/Int_Changer.value = variable
			suppress_change = false
			
	if typeof(variable) == TYPE_INT:
		target_variable_name = list.get_item_text(index)
		$CanvasLayer/Int_Changer.visible = true
		suppress_change = true
		$CanvasLayer/Int_Changer.value = variable
		suppress_change = false
	else:
		target_variable_name = ""
		$CanvasLayer/Int_Changer.visible = false
	process_chain()
	process_variable_editors(typeof(variable))

func _on_Parameter_Lists_item_activated(index):
	var list = $CanvasLayer/Parameter_Lists
	var variable = target_variable_parent.get(list.get_item_text(index))
	match typeof(variable):
		TYPE_OBJECT:
			debug_chain.push_back(list.get_item_text(index))
			target_variable_parent = variable;
			clear_list()
			process_parameter_list()

func _on_Int_Changer_value_changed(value):
	if !suppress_change:
		var variable_key = debug_chain.duplicate()
		variable_key.push_back(target_variable_name)
		Game_Constants.variable_changes_dict[variable_key] = value;
		Game_Constants.process_changes();
		target_variable_parent.set(target_variable_name, value)

func process_variable_editors(variable_type):
	set_Int_Changer_access(variable_type == TYPE_INT || variable_type == TYPE_REAL)
	

func set_Int_Changer_access(state:bool):
	$CanvasLayer/Int_Changer.visible = state
	if state:
		suppress_change = true
		print(target_variable_parent, target_variable_name)
		$CanvasLayer/Int_Changer.value = target_variable_parent.get(target_variable_name)
		suppress_change = false
	pass

func process_chain():
	var current_variable = debug_chain[0]
	for i in range(1,debug_chain.size()):
		current_variable = current_variable.get(debug_chain[i]);
	target_variable_parent = current_variable
	var selected_item_array = $CanvasLayer/Parameter_Lists.get_selected_items();
	if selected_item_array.size() != 0:
		target_variable_name = $CanvasLayer/Parameter_Lists.get_item_text(selected_item_array[0])
	return current_variable

func disable_focus():
	$CanvasLayer/Int_Changer.release_focus()
	$CanvasLayer/Int_Changer.get_line_edit().release_focus()
	$CanvasLayer/Parameter_Lists.release_focus()


func _on_Scene_Reset_pressed():
	get_tree().reload_current_scene()

func screen_resize():
	print("Screen Size changing")
