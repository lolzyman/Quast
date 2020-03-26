extends Node

func reinstate_changes():
	process_changes()

func _ready():
	print("Game_Constants has been Loaded")
	pass

#warning-ignore:unused_class_variable
var _dummyString = "Message To Display";

#warning-ignore:unused_class_variable
var connected_players_array = [];

var variable_changes_dict = {}

func process_changes():
	for key in variable_changes_dict.keys():
		if key[0] == self:
			if self.get(key[1]) != null:
				print(self.get(key[1]))
				var var_array = search_for_filename(self.get(key[1]).filename)
				for item in var_array:
					item.set(key[2], variable_changes_dict[key])

enum weapon_types {SMALL_ARC = 0, FULL_ARC = 1, HALF_ARC = 2}

var player_size = 64 setget set_player_size

const player_filepath := "res://Templates/GameEntities/Characters/Dummy Player.tscn"
const projectile_filepath := "res://Templates/GameEntities/Projectile.tscn"
export (Resource) var player_node = preload(player_filepath).instance();
export (Array) var managable_filepaths = [player_filepath, projectile_filepath]

func set_player_size(new_value):
	player_size = new_value;
	var found_players = search_for_filename(player_filepath)
	for player in found_players:
		player.scale = Vector2(new_value/64,new_value/64)
		pass

func search_for_player() -> Array:
	var scene_parent = get_tree().get_current_scene();
	var found_player_array  := [];
	recursive_player_search(scene_parent, found_player_array);
	return found_player_array

func search_for_filename(filename:String) ->Array:
	var scene_parent = get_tree().get_current_scene();
	var found_objects_array  := [];
	recursisve_filename_search(scene_parent, found_objects_array, filename);
	return found_objects_array
	pass

func recursisve_filename_search(node:Node, found_objects_array, filename):
	for child in node.get_children():
		if child.filename == player_filepath:
			found_objects_array.push_back(child)
		else:
			recursisve_filename_search(child, found_objects_array, filename)
		pass

func recursive_player_search(node:Node, player_array:Array):
	for child in node.get_children():
		if child.filename == player_filepath:
			player_array.push_back(child)
		else:
			recursive_player_search(child, player_array)
		pass
	