extends KinematicBody2D

#Variables necessary to the character as an entity

var motion : = Vector2();
export (PackedScene) var projectile
export var SPEED = 100;
export (NodePath) var Projectile_Carrier_Path
export (NodePath) var Enemy_Carrier_Path
export (NodePath) var Item_Carrier_Path
export (PackedScene) var default_attack_sprite
export (PackedScene) var default_attack_collider
export (float) var size_modifier = 64 setget set_size
var Projectile_Carrier;
var Enemy_Carrier;
var Item_Carrier;

func set_size(_new_size):
	pass

export (float) var max_health = 100
var health

#warning-ignore:unused_class_variable
var managed_inventory:Managed_Inventory = Managed_Inventory.new();

var inventory:Dictionary;
var inventory_next_key = 0;
var inventory_change_flag = false;
#warning-ignore:unused_class_variable
var equipment:Dictionary;
var equipment_change_flag = false;
signal set_attack;
signal set_ranged_attack;
signal examine_items;
signal health_update(health_percentage)
signal update_inventory;

var attackCooldownTimer = 0;
var projectile_shoot_speed = 100;
var projectile_shoot_range = 500;

#Initializer for the Character
func _ready():
	add_child(managed_inventory);
	#Old implementation for multiplayer servers
	Game_Constants.connected_players_array.append(self);
	
	#Groups necessary for functionality
	add_to_group("Player");
	add_to_group("Character");
	add_to_group("Game_Entity");
	
	#Signal Connection for handling ranged attak
	var _err = connect("set_ranged_attack", $Ranged_Monitor, "attack_call")
	Projectile_Carrier = get_node(Projectile_Carrier_Path);
	Enemy_Carrier = get_node(Enemy_Carrier_Path);
	Item_Carrier = get_node(Item_Carrier_Path);
	$Ranged_Monitor.Projectile_Carrier = Projectile_Carrier;
	$Ranged_Monitor.connected_to_player = true;
	$Melee_Monitor.default_attack_collider = default_attack_collider
	$Melee_Monitor.default_attack_sprite = default_attack_sprite
	$Melee_Monitor.ready_default_weapon(true);
	health = max_health;
	intialize_equipment()
	$Health_Bar.set_health(100);
	
func intialize_equipment():
	for value in globals.equipment_keywords:
		equipment[globals.equipment_keywords[value]] = null;
	process_equipment()
	
func equip(equip_item:Node2D, equip_placeholder_keyword):
	if(equipment[equip_placeholder_keyword] != null):
		unequip(get_node(equipment[equip_placeholder_keyword]["UI_Item_Nodepath"]))
	equipment[equip_placeholder_keyword] = equip_item.source_dictionary;
	equipment_change_flag = true;
	
func recieve_damage(damage_value, _damage_type):
	#print("I was supposed to take ", damage_value, " ", damage_type, " damage");
	health -= damage_value;
	emit_signal("health_update", health * 100 / max_health)
	pass

func unequip(item:Node2D):
	for key in equipment.keys():
		if equipment[key] == item.source_dictionary:
			equipment[key] = null
			equipment_change_flag = true;
			return

func right_hand_equipment_handler(new_item, old_item):
	print("Right Hand Equipment Handler Function")
	print(new_item, old_item);
	if new_item.empty():
		return
	var new_item_information = new_item["Item"];
	print(new_item_information)
	var item_info = new_item_information.instance().get_item_info();
	if item_info.has_all(["Melee_Damage_Value", "Melee_Damage_Type","Attack_Sprite","Attack_Collider"]):
		$Melee_Monitor.ready_weapon(item_info)
	pass
	var x = 10;
	x += 12;
	pass

func _physics_process(_delta):
	if Input.is_action_pressed("ui_right"):
		motion.x = SPEED;
	elif Input.is_action_pressed("ui_left"):
		motion.x = -SPEED;
	else:
		motion.x = 0;
	if Input.is_action_pressed("ui_up"):
		motion.y = -SPEED;
	elif Input.is_action_pressed("ui_down"):
		motion.y = SPEED;
	else:
		motion.y = 0;
	if Input.is_action_just_pressed("game_melee"):
		emit_signal("set_attack");
		
	var _linear_velocity = move_and_slide(motion);
	look_at(get_global_mouse_position());
	if(!globals.private_game):
		networkSync()
	if Input.is_action_just_pressed("game_gather_items"):
		emit_signal("examine_items", inventory);
		gather_all_items();
		#open_item_get_menu();
	
	if Input.is_action_just_pressed("game_interact"):
		var already_Interacted = false
		var otherAreas = $Item_Interact_Area.get_overlapping_areas()
		for area in otherAreas:
			if area.is_in_group("Interactable"):
				if !already_Interacted:
					already_Interacted = true;
					area.interact(self);
	
	if Input.is_action_just_pressed("game_shoot"):
		emit_signal("set_ranged_attack")
	
	if Input.is_action_just_pressed("engine_debug"):
		print(Game_Constants.search_for_player())
	
	if Input.is_action_just_pressed("engine_close"):
		get_tree().quit();
	
	if inventory_change_flag:
		process_inventory();
		get_tree().get_current_scene().user_interface.update_from_inventory();
		inventory_change_flag = false;
	if equipment_change_flag:
		process_equipment()
		equipment_change_flag = false;
	if health <= 0:
		#print("Game Over!!!")
		pass

func process_equipment():
	if equipment[globals.equipment_keywords.R_HAND] != null:
		var item_data:Dictionary = equipment[globals.equipment_keywords.R_HAND];
		var item_node = get_node(item_data["UI_Item_Nodepath"]);
		var item_info:Dictionary = item_node.get_item_info();
		print(item_info);
		$Melee_Monitor.ready_weapon(item_info)
	else:
		$Melee_Monitor.ready_default_weapon();
	if equipment[globals.equipment_keywords.AMMO] != null:
		var item_data:Dictionary = equipment[globals.equipment_keywords.AMMO];
		var item_node = get_node(item_data["UI_Item_Nodepath"]);
		$Ranged_Monitor.current_requested_ammo = item_data["Item_Type"]
		$Ranged_Monitor.expected_projectile = item_node.get_projectile();
	else:
		$Ranged_Monitor.current_requested_ammo = null
		$Ranged_Monitor.expected_projectile = null;
	pass

func process_inventory():
	managed_inventory.update();
	# Remove any empty Items
	for item in inventory.keys():
		if inventory[item]["Quantity"] <= 0:
			if inventory[item] != null:
				get_tree().get_current_scene().user_interface.remove_from_ui(inventory[item])
			if is_item_equipped(inventory[item]):
				unequip(get_node(inventory[item]["UI_Item_Nodepath"]));
				equipment_change_flag = true;
			# warning-ignore:return_value_discarded
			inventory.erase(item);
	pass

func is_item_equipped(item:Dictionary) -> bool:
	var item_hash = hash(item);
	for item_slot in equipment.values():
		var item_slot_hash = hash(item_slot);
		if(item_hash == item_slot_hash):
			return true;
			# This code shouldn't be needed becuase the hashs should realistiaclly never be the same
			# It is simiple enough to write but might slow down the computer so its left out until a bug is found
			# warning-ignore:unreachable_code
			for item_key in item.keys():
				for item_slot_key in item_slot.keys():
					if item[item_key] == item_slot[item_slot_key]:
						return true;
		pass
	return false;

func open_item_get_menu():
	#Load Item Pickup UI
	#Populate Item Pickup UI from globals
	#Allow User to pick Items
	pass

func gather_all_items():
	pass

func networkSync():
	sync_position(position);
	sync_orientation(rotation);
	
remote func sync_position(master_position):
	position = master_position

remote func sync_orientation(master_angle):
	rotation = master_angle
