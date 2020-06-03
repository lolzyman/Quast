extends Area2D

var attackCooldown = 0.5;
enum attack_states {PREPARED = 0, ATTACKING = 1, COOLINGDOWN = 2}
var timerNode = Timer.new();
var current_state = attack_states.PREPARED;
var damage_type = "slashing";
var damage_value = 10;
export var default_damage_type := "slashing"
export var default_damage_value := 10;
export (Array, PackedScene) var possible_attack_patterns
export (PackedScene) var default_attack_sprite
export (PackedScene) var default_attack_collider
var current_attack_sprite:Sprite;
var current_attack_collider:CollisionPolygon2D

func _ready():
	var _err = get_parent().connect("set_attack", self, "start_attack");
	_err = timerNode.connect("timeout", self, "timer_finished");
	timerNode.one_shot = true;
	add_child(timerNode)

func timer_finished():
	match current_state:
		attack_states.COOLINGDOWN:
			current_attack_sprite.visible = false;
			#$Attack_Sprite.visible = false;
			current_state = attack_states.PREPARED
		attack_states.ATTACKING:
			print(get_overlapping_bodies())
			assign_damage_to_bodies(get_overlapping_bodies());
			current_attack_collider.disabled = true;
			#$Attack_Collider.disabled = true;
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
		current_attack_sprite.visible = true;
		#$Attack_Sprite.visible = true;
		current_attack_collider.disabled = false;
		#$Attack_Collider.disabled = false;
		#Set for two frames to ensure collision
		timerNode.start(0.02)

func ready_weapon(weapon:Dictionary):
	if(weapon.has_all(["Attack_Sprite","Attack_Collider","Melee_Damage_Type","Melee_Damage_Value"])):
		set_attack_sprite(weapon["Attack_Sprite"])
		set_attack_collider(weapon["Attack_Collider"])
		damage_type = weapon["Melee_Damage_Type"]
		damage_value = weapon["Melee_Damage_Value"]
		return
	print("Help you haven't configured things right for the weapon")

func set_attack_sprite(new_sprite:PackedScene):
	if current_attack_sprite:
		current_attack_sprite.queue_free()
	current_attack_sprite = new_sprite.instance();
	add_child(current_attack_sprite)

func set_attack_collider(new_collider:PackedScene):
	if current_attack_collider != null:
		current_attack_collider.queue_free()
	current_attack_collider = new_collider.instance()
	add_child(current_attack_collider)

func ready_default_weapon(override = false):
	set_attack_sprite(default_attack_sprite);
	set_attack_collider(default_attack_collider);
	damage_type = default_damage_type
	damage_value = default_damage_value
