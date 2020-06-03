#This class handes all the Loading for 
extends Node
export (PackedScene) var admin_camera;
export (PackedScene) var default_player;
export (Vector2) var spawn_location;
export (PackedScene) var user_interface;
export (PackedScene) var loot_bag;
export (NodePath) var current_player;
func _ready():
	Game_Constants.reinstate_changes()
	current_player = get_node(current_player);
	user_interface = user_interface.instance();
	add_child(user_interface);
	user_interface.character = current_player;
	user_interface.character_inventory = current_player.inventory;
	user_interface.character_equipment = current_player.equipment;
	print("World Is Initalizing")
	if(globals.private_game == false):
		if(globals.is_server):
			print("Hello I am a server")
			_Instantiate_admin_camera()
			remove_all_players()
			remove_all_enemies()
			var _err = globals.connect("_addPlayer", self, "add_player")
		else:
			print("Hello I am a client trying to connect")
			#print("I need to add myself")
			#add_player(get_tree().get_network_connected_peers())
func _process(delta):
	if(Input.is_action_just_pressed("game_pause")):
		if(get_tree().paused == true):
			get_tree().paused = false;
		else:
			get_tree().paused = true;
			

func _Instantiate_admin_camera():
	var new_camera = admin_camera.instance()
	new_camera.position = Vector2(0,0)
	add_child(new_camera)

func remove_all_enemies():
	for entity in $Enemies.get_children():
		pass
	pass

func remove_all_players():
	var entities = $Players.get_children();
	for entity in entities:
		entity.queue_free()
	pass

func add_player(player_network_id):
	print(player_network_id);
	print("Hi i Exist now")
	var new_player = default_player.instance()
	new_player.set_name(str(player_network_id))
	new_player.position = spawn_location
	new_player.set_network_master(player_network_id)
	$Players.add_child(new_player)

func spawn_loot_bag(location:Vector2, item_array = []):
	var newLootBag:Node2D = loot_bag.instance();
	newLootBag.add_item_array_to_bag(item_array)
	$Items.add_child(newLootBag);
	newLootBag.position = location;
	pass
