extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var target_player = null;
export (NodePath) var target_player_path;

# Called when the node enters the scene tree for the first time.
func _ready():
	if target_player_path != null:
		target_player = get_node(target_player_path);
		target_player.managed_inventory.temp_target = $"CanvasLayer/Inventory Overlay";
		$"CanvasLayer/Inventory Overlay".prep_from_dictionary(target_player.managed_inventory.inventory);
		print("Error value: ", target_player.managed_inventory.connect("inventory_update", $"CanvasLayer/Inventory Overlay", "update_inventory"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target_player != null:
		position = target_player.position
#	pass

func _input(event):
	if event is InputEventKey:
		var Inventory_UI : Inventory_User_Interface = $"CanvasLayer/Inventory Overlay";
		if event.pressed:
			match(event.as_text()):
				"I":
					Inventory_UI.toggle_view()

func test_playground():
	var dict_a = {1: "Apples", 2:"Bananas"};
	var dict_b = {2: "Cherries", 3:"Dragon  Fruit"}
	var dict_c = {dict_a: "Elderberry", dict_b: "Fig"}
	display_dicts(dict_a, dict_b, dict_c);
	dict_a[1] = "Soup";
	display_dicts(dict_a, dict_b, dict_c);

func display_dicts(dict_a, dict_b, dict_c):
	print(dict_a)
	print(dict_b)
	print(dict_c)
