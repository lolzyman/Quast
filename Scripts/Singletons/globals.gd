extends Node

enum item_keywords {HEAD = 0, TORSO = 1, LEGS = 2, FEET = 3, R_HAND = 4, L_HAND = 5, AMMO = 6, R_GLOVE = 7, L_GLOVE = 8}
enum equipment_keywords {HEAD = 0, TORSO = 1, LEGS = 2, FEET = 3, R_HAND = 4, L_HAND = 5, AMMO = 6, R_GLOVE = 7, L_GLOVE = 8}

#warning-ignore:unused_class_variable
var other_player_ids = [];

export var dummy_int := 10 setget set_int

func set_int(new_value):
	print("Jackabo")
	dummy_int = new_value

#warning-ignore:unused_class_variable
var is_server = false;

#warning-ignore:unused_class_variable
#Contains pointers to the information about each enemy.
var enemies_to_send = [];

#warning-ignore:unused_class_variable
#Contains pointers to each pressure plate so that the server can handle inf
var pressure_plate_states = [];

#warning-ignore:unused_class_variable
var players_to_send = [];

#warning-ignore:unused_class_variable
var private_game = false;

signal _addPlayer(player_ID);
signal _removePlyaer(player_ID);
signal _handle_Item_Collection(Item);

func collect_Item(Item):
	print("Supposed to be picking up an Item")
	emit_signal("_handle_Item_Collection", Item);

func add_player(player_ID):
	print("I got called")
	emit_signal("_addPlayer", player_ID)

func remove_player(player_ID):
	emit_signal("_removePlyaer", player_ID)
