extends Area2D

var attackCooldown = 0.5;
enum attack_states {PREPARED = 0, ATTACKING = 1, COOLINGDOWN = 2}
var timerNode = Timer.new();
var current_state = attack_states.PREPARED;
var damage_type = "Cutting";
var damage_value = 10;

func _ready():
	pass

func timer_finished():
	match current_state:
		attack_states.COOLINGDOWN:
			$Attack_Sprite.visible = false;
			current_state = attack_states.PREPARED
		attack_states.ATTACKING:
			assign_damage_to_bodies(get_overlapping_bodies());
			$Attack_Collider.disabled = true;
			current_state = attack_states.COOLINGDOWN;
			timerNode.start(attackCooldown)
		attack_states.PREPARED:
			print("This is something that should never be reached");
		_:
			print("Something is going wrong over here");

func assign_damage_to_bodies(bodies):
	for body in bodies:
		if body.is_in_group("Game_Entity"):
			body.recieve_damage(damage_value, damage_type)

func start_attack():
	if current_state == attack_states.PREPARED:
		current_state = attack_states.ATTACKING
		$Attack_Sprite.visible = true;
		$Attack_Collider.disabled = false;
		#Set for two frames to ensure collision
		timerNode.start(0.02)

func ready_weapon(weapon_type):
	
	pass