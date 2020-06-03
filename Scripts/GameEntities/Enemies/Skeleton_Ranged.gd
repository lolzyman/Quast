extends Base_Enemy

# Variables that are accessible
# targetPlayer

var skeleton_ranged_attack_range = 500;
var skeleton_ranged_retreat_range = 200;
var skeleton_ranged_attacking = false;

func _ready():
	var _err 
	_err = connect("playerMovement", self, "Skeleton_Ranged_PlayerMovement");
	_err = connect("nonPlayerMovement", self, "Skeleton_Ranged_NonPlayerMovement");
	_err = connect("recieve_damage", self,"Skeleton_Ranged_on_damage");
	_err = connect("on_death", self, "Skeleton_Ranged_on_death");
	$Ranged_Monitor.Projectile_Carrier = Projectile_Carrier

func Skeleton_Ranged_PlayerMovement(_delta):
	var target_player_distance = position.distance_to(targetPlayer.position);
	if target_player_distance <= skeleton_ranged_retreat_range:
		#retreat
		#print("AAAHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
		return
	if position.distance_to(targetPlayer.position) < skeleton_ranged_attack_range:
		#attack
		look_at_target_player();
		ranged_attack()
		return
	#advance
	#print("CHARGEEEEEEE")
	pass

func Skeleton_Ranged_NonPlayerMovement(_delta):
	#return to post
	pass

func ranged_attack():
	$Ranged_Monitor.attack_call()
	pass

func advance():
	
	pass

func retreat():
	pass

func Skeleton_Ranged_on_death():
	print(get_tree().get_current_scene().get_name())
	get_tree().get_current_scene().spawn_loot_bag(position, process_loot());
	pass

func Skeleton_Ranged_on_damage(_damage_type, damage_value):
	health -= damage_value
	pass
