extends Area2D

var occupied = false;
var owned_item = null;
enum placeholder_options {INVENTORY, EQUIPMENT}
enum item_keyword_options {APPLE}
export (bool) var can_accept_anything = true
export (placeholder_options) var placeholder_type;
export (globals.item_keywords) var accepted_keyword

func _ready():
	add_to_group("UI_Item_Placeholder");

func accept_item(item:Node2D) -> bool:
	if can_combine(item):
		return false;
	if occupied:
		owned_item.combine_with(item);
		item.queue_free()
		return true
	item.position = position;
	item.current_placeholder = self
	owned_item = item
	self.occupied = true;
	return true

func can_equip(item:Node2D) -> bool:
	if placeholder_type != placeholder_options.EQUIPMENT:
		return false
	for keyword in item.keywords:
		if keyword == accepted_keyword:
			return true
	return false

func can_combine(item:Node2D) -> bool:
	if occupied:
		if owned_item.check_if_same_item(item):
			return true;
		else:
			return false;
	return false;