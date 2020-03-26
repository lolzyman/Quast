extends RigidBody2D

export var Speed := 50
export (NodePath) var Projectile_Carrier_Path
export (Array, Dictionary) var expected_loot_drop
export (float) var max_health = 100
onready var myVision = get_node("VisionRay")
var targetPlayer = null;
var visible_players = [];
var all_inrange_players = [];
var Projectile_Carrier
var health

signal playerMovement(delta);
signal nonPlayerMovement(delta);
signal health_update(health_percentage)
signal recieve_damage(damage_type, damage_amount);
signal on_death();

##
## Internal Scripts
## - These are used to handle 
func _ready():
	add_to_group("Game_Entity");
	add_to_group("Enemy");
	Projectile_Carrier = get_node(Projectile_Carrier_Path);
	health = max_health
func _physics_process(delta):
	#Gather All Visible Players
	all_inrange_players = get_inrange_players();
	visible_players = get_visible_players();
	#Handles Movement
	if(!follow_entity(delta)):
		idle_movement(delta)
func follow_entity(delta):
	targetPlayer = select_closest_player(visible_players)
	if targetPlayer == null:
		return false
	if get_signal_connection_list("playerMovement").size() > 0:
		emit_signal("playerMovement", delta);
	else:
		defaultPlayerMovement(delta);
	return true
func idle_movement(delta):
	if get_signal_connection_list("nonPlayerMovement").size() > 0:
		emit_signal("nonPlayerMovement", delta);
	else:
		defaultNonPlayerMovement(delta);
	pass
func defaultPlayerMovement(delta):
	if look_at_target_player():
		var movementDirection = Vector2(cos(rotation), sin(rotation))
		translate(movementDirection * Speed * delta)
func defaultNonPlayerMovement(_delta):
	print("Unbound Signal idle movement")
	pass

##
## Player related Methods 
## - These methods are for handling how players are seen

func look_at_target_player() -> bool:
	if is_player_visible(targetPlayer):
		look_at(targetPlayer.global_position);
		return true;
	return false;
func is_player_visible(player_in_question):
	myVision.cast_to = Vector2(global_position.distance_to(player_in_question.global_position),0)
	myVision.rotation = get_angle_to(player_in_question.global_position)
	if(myVision.is_colliding()):
		if myVision.get_collider() == player_in_question:
			return true;
	return false;
func get_inrange_players():
	if $VisionArea == null:
		return
	var inrange_players = []
	var visibleEntities = $VisionArea.get_overlapping_bodies();
	for entity in visibleEntities:
		if(entity.is_in_group("Player")):
			inrange_players.push_back(entity)
	return inrange_players
func select_closest_player(array_of_players):
	var current_closest_player = null;
	var current_distance = INF;
	for player in array_of_players:
		var player_distance = self.global_position.distance_to(player.global_position);
		if player_distance < current_distance:
			current_distance = player_distance
			current_closest_player = player
	return current_closest_player
func get_visible_players():
	var all_visible_players = [];
	for player in all_inrange_players:
		if is_player_visible(player):
			all_visible_players.push_back(player);
	return all_visible_players;

##
## Externally Called Methods
## - These Methods are expected to be called by external sources

func dying():
	emit_signal("on_death");
	queue_free()
	pass
func spawn_loot():
	get_tree().get_current_scene().spawn_loot_bag(position);
	pass
func recieve_damage(damage_value, damage_type):
	#print("I was supposed to take ", damage_value, " ", damage_type, " damage");
	emit_signal("recieve_damage", damage_type, damage_value);
	emit_signal("health_update", health*100/max_health)
	if health <= 0:
		dying()
func process_loot() -> Array:
	print("Processing the loot!!")
	var item_array = []
	for spawn_loot in expected_loot_drop:
		if(typeof(spawn_loot) != TYPE_DICTIONARY):
			print("This isn't a dictionary");
			return []
		if !spawn_loot.has_all(["Item","Quantity","Probability","Stackable"]):
			print("The dictionary isn't formatted properly");
			return []
		var new_dictionary = {};
		var quantity = 0
		var max_quantity = spawn_loot["Quantity"]
		var threshold = spawn_loot["Probability"]
		while max_quantity > 0:
			max_quantity -= 1;
			var rand_number = rand_range(0, 99);
			if rand_number < threshold:
				quantity += 1;
		new_dictionary["Item_Type"] = spawn_loot["Item"];
		new_dictionary["Quantity"] = quantity
		new_dictionary["Stackable"] = spawn_loot["Stackable"]
		new_dictionary["UI_Item_Nodepath"] = null
		new_dictionary["UI_Placeholder_Nodepath"] = null
		item_array.push_back(new_dictionary)
	return item_array