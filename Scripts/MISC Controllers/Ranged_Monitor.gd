extends Node2D

export (Array, PackedScene) var projectile_types;
var Projectile_Carrier
enum possible_attack_states {COOLING_DOWN, READY}

var current_state = possible_attack_states.READY
var cooldown_timer = Timer.new();
var Inventory_Reference;

export (PackedScene) var expected_projectile
export (PackedScene) var current_requested_ammo
var current_usable_ammo

var attack_cooldown = 1; #In Seconds
var constant_attacking = false;
var projectile_lead_distance = 50;
var projectile_shoot_speed = 100;
var projectile_shoot_range = 500;
var connected_to_player = false;
func _ready():
	cooldown_timer.connect("timeout", self, "cooldown_finished")
	cooldown_timer.one_shot = true;
	print("No trigger")
	add_child(cooldown_timer)

func cooldown_finished():
	match current_state:
		possible_attack_states.COOLING_DOWN:
			if constant_attacking:
				launch_projectile();
			else:
				current_state = possible_attack_states.READY
		possible_attack_states.READY:
			print("This should never be called. See the Ranged_Monitor")

func attack_call():
	if current_state == possible_attack_states.READY:
		launch_projectile()
		cooldown_timer.start(attack_cooldown)
		current_state = possible_attack_states.COOLING_DOWN

func launch_projectile():
	if connected_to_player:
		var character_inventory:Dictionary = get_parent().inventory;
		var character_equipment:Dictionary = get_parent().equipment;
		print(character_inventory.keys());
		if(current_requested_ammo == null):
			print("You have nothing equipped");
			return
		for item in character_inventory.keys():
			if(character_inventory[item]["Item_Type"] == current_requested_ammo):
				if character_inventory[item]["Quantity"] > 0:
					character_inventory[item]["Quantity"] -= 1;
					var spawned_projectile = expected_projectile.instance();
					spawned_projectile.init(get_parent().position, get_parent().rotation, projectile_shoot_speed, projectile_shoot_range, projectile_lead_distance);
					spawned_projectile.spawning_entity = get_parent()
					Projectile_Carrier.add_child(spawned_projectile);
					get_parent().inventory_change_flag = true
				else:
					print("You Are Out Of Ammo")
			else:
				print("You Don't Have the Desired Ammo")
				print(current_requested_ammo)
	else:
		var spawned_projectile = expected_projectile.instance();
		spawned_projectile.init(get_parent().position, get_parent().rotation, projectile_shoot_speed, projectile_shoot_range, projectile_lead_distance);
		spawned_projectile.spawning_entity = get_parent()
		Projectile_Carrier.add_child(spawned_projectile);
		

func load_weapon_states():
	pass