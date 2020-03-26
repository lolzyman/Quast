extends Node2D
#const gameSceneLocation = "res://Dummy.tscn";
const gameSceneLocation = "res://Pong_Game.tscn";
export (PackedScene) var starterLevel;
export (PackedScene) var debugLevel;

func _ready():
	var _err = get_tree().connect("network_peer_connected", self, "_handle_peer_connected")

func _handle_peer_connected(peer_id):
	if(globals.is_server):
		print("I was lanuched as a server already and a player is connecting")
		print("Player Connected")
		globals.other_player_ids.push_back(peer_id);
		print(globals.other_player_ids)
		globals.emit_signal("_addPlayer", peer_id)
	else:
		globals.other_player_ids.push_back(peer_id)
		start_game()
		return

func _on_HostGame_pressed():
	print("Hosting Game")
	var host = NetworkedMultiplayerENet.new()
	var res = host.create_server(4242)
	if res != OK:
		print("Something went wrong creating the server")
		return
	get_tree().set_network_peer(host)
	globals.is_server = true;
	start_game()

func _on_JoinGame_pressed():
	print("Joining Game")
	var client = NetworkedMultiplayerENet.new()
	client.create_client("127.0.0.1",4242)
	get_tree().set_network_peer(client)
	$HostGame.hide()
	$JoinGame.disabled = true;

func start_game():
	get_tree().get_root().add_child(starterLevel.instance());
	hide();
	pass

func start_game2():
	var newScene = starterLevel.instance();
	get_tree().get_root().add_child(newScene);
	get_tree().set_current_scene(newScene);
	hide();

func start_debug_level():
	get_tree().get_root().add_child(debugLevel.instance());
	hide();
	pass

func _on_Private_Game_pressed():
	globals.private_game = true;
	start_game2();
	pass

func _Launch_Debug_Level():
	start_debug_level()
	globals.private_game = true;
	return
