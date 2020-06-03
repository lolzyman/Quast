extends TextureRect

enum function_type {inventory_slot, equipment_slot}
enum equipment_slot_type {head, left_hand, right_hand, torso, legs, feet}
export (function_type) var my_function = function_type.inventory_slot;
export (equipment_slot_type) var my_equipment_function;
var following_mouse = false;
var mirror_me;
var quantity = 1 setget set_quantity;
var occupied = false;
var image_Sprite : Node = Sprite.new();
var my_item_dictionary = {};
class_name Item_Element_Class

signal item_change(moving_item_slot, stationary_item_slot)

func _ready():
	add_to_group("Item_Element");
	add_child_below_node($"Overlap Detector",image_Sprite);

#func _process(_delta):
#	pass

func set_quantity(new_quantity):
	quantity = new_quantity;
	$Quantity_Label.text = str(quantity);
	if quantity == 1:
		$Quantity_Label.visible = false;
	else:
		$Quantity_Label.visible = true;
	if quantity == 0:
		print("Error in Item_Element, set_quantity, unexpected condition");

func _gui_input(event):
	if event is InputEventMouseMotion:
		if following_mouse:
			mirror_me.rect_position = get_global_mouse_position() - rect_size/2;
	if event is InputEventMouseButton:
		if event.pressed == true:
			mirror_me = duplicate();
			mirror_me.texture = null;
			var new_parent = get_tree().get_root()
			new_parent.add_child(mirror_me);
			following_mouse = true;
			mirror_me.rect_position = get_global_mouse_position() - rect_size/2;
		else:
			following_mouse = false;
			var colliding_areas = mirror_me.get_child(0).get_overlapping_areas();
			colliding_areas.sort_custom(self, "custom_sorter");
			if !colliding_areas.empty():
				emit_signal("item_change", self, colliding_areas[0].get_parent());
			mirror_me.get_parent().remove_child(mirror_me);

func update_item(item : Dictionary):
	if item.empty():
		clear();
		return;
	remove_child(image_Sprite);
	image_Sprite = item["Item"].instance();
	self.quantity = item["Quantity"];
	add_child_below_node($"Overlap Detector", image_Sprite);
	my_item_dictionary = item;

func clear():
	my_item_dictionary = {};
	$Quantity_Label.visible = false;
	image_Sprite.texture = null;
	pass

func is_empty() -> bool:
	if my_item_dictionary.empty():
		return true;
	return false;

func custom_sorter(a, b):
	return mirror_me.rect_position.distance_squared_to(a.get_parent().get_global_rect().position) < mirror_me.rect_position.distance_squared_to(b.get_parent().get_global_rect().position);
