extends Area2D


# Public Variables
# warning-ignore:unused_class_variable
export (Array, globals.item_keywords) var keywords;
enum placeholder_interaction_results {no_interaction = 0, item_moved = 1, item_equipped = 2, item_combined = 3, item_unequipped = 4, item_returning_home = 5}
var last_position = false;
var current_placeholder = null;
var quantity = 1;
# warning-ignore:unused_class_variable
var source_dictionary:Dictionary;

# Private Variables
var is_dragging = false;
var mouse_is_over = false;
#This needs to be unique across all items.
var object_id_string = "Generic Item"
# warning-ignore:unused_class_variable

func _process(_delta):
	if is_dragging:
		position = get_global_mouse_position();

func _input(event):
	if event is InputEventMouseButton:
		# Handles Left Mouse Button
		if event.button_index == 1:
			if event.pressed:
				if mouse_is_over:
					_start_dragging();
			else:
				_check_snap();

func _mouse_entered():
	mouse_is_over = true;

func _check_snap():
	if is_dragging:
		var distance_lookup = {};
		var distance_array = [];
		for UI_Element in get_overlapping_areas():
			if UI_Element.is_in_group("UI_Item_Placeholder"):
				var distance_to_UI_Element = position.distance_to(UI_Element.position);
				while(distance_lookup.has(distance_to_UI_Element)):
					distance_to_UI_Element += 0.0001;
				distance_lookup[distance_to_UI_Element] = UI_Element;
				distance_array.push_back(distance_to_UI_Element);
		distance_array.sort();
		var interaction_successful = false;
		for distance in distance_array:
			print(source_dictionary);
			var interaction_value = interact_with_placeholder(distance_lookup[distance]);
			match interaction_value:
				placeholder_interaction_results.item_moved:
					interaction_successful = true;
					break
				placeholder_interaction_results.item_combined:
					print("We need to talk, you haven't implemented item spilting")
				placeholder_interaction_results.item_equipped:
					# Passes off contorl to the UI to handle placement
					interaction_successful = true;
					break
				placeholder_interaction_results.item_unequipped:
					print("I wonder if this ever gets called")
					interaction_successful = true;
					break
				placeholder_interaction_results.item_returning_home:
					print("This was a weird problem")
					interaction_successful = true;
					break;
				placeholder_interaction_results.no_interaction:
					#Nothing Happend, continue the looping
					pass
		if !interaction_successful:
			return_to_last_position();
	is_dragging = false;

func interact_with_placeholder(placeholder) -> int:
	if(placeholder == current_placeholder):
		return_to_last_position();
		return placeholder_interaction_results.item_returning_home;
	if(placeholder.placeholder_type == placeholder.placeholder_options.EQUIPMENT):
		if(placeholder.can_equip(self)):
			get_tree().get_current_scene().user_interface.update_to_inventory(self, placeholder, "Item_Equipping");
			position = placeholder.position;
			current_placeholder.occupied = false;
			placeholder.occupied = true;
			current_placeholder = placeholder;
			return placeholder_interaction_results.item_equipped
		print("This doesn't go in that slot")
	else:
		var dequip_flag = false;
		if current_placeholder.placeholder_type == current_placeholder.placeholder_options.EQUIPMENT:
			dequip_flag = true;
			pass
		if placeholder.accept_item(self):
			position = placeholder.position;
			current_placeholder.occupied = false;
			placeholder.occupied = true;
			current_placeholder = placeholder;
			if dequip_flag:
				get_tree().get_current_scene().user_interface.update_to_inventory(self, placeholder, "Item_Unequipping");
				return placeholder_interaction_results.item_unequipped;
			else:
				get_tree().get_current_scene().user_interface.update_to_inventory(self, placeholder, "Item_Moving");
				return placeholder_interaction_results.item_moved;
	return placeholder_interaction_results.no_interaction;

func _start_dragging():
	is_dragging = true;
	if current_placeholder == null:
		last_position = position;
	else:
		last_position = current_placeholder.position;

func _mouse_exited():
	mouse_is_over = false;

func combine_with(other_item):
	quantity += other_item.quantity;
	if quantity == 1:
		$Quantity.visible = false;
	else:
		$Quantity.visible = true;
		$Quantity.text = str(quantity);

func return_to_last_position():
	position = last_position;
	pass

func check_if_same_item(other_item):
	if other_item.object_id_string == object_id_string:
		return true;
	else:
		 return false

func refresh():
	if quantity == 1:
		$Quantity.visible = false;
	else:
		$Quantity.visible = true;
		$Quantity.text = str(quantity);
