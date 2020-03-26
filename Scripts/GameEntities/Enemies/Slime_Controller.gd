extends "res://Scripts/GameEntities/Enemies/EnemyController.gd"

export (float) var slime_max_cooldown_duration = 0.5; 
var slime_cooldown_timer = 0;
export (float) var slime_max_move_duration = .125;
var slime_move_timer = 0;
export (float) var slime_move_speed = 300;
export (PackedScene) var small_slime
func _ready():
	var _err = connect("playerMovement", self, "slimePlayerMovement");
	_err = connect("nonPlayerMovement", self, "slimeNonPlayerMovement");
	_err = connect("recieve_damage", self,"slime_on_damage");
	_err = connect("on_death", self, "slime_on_death");

func slimePlayerMovement(delta):
	if slime_cooldown_timer <= 0:
		if slime_move_timer == slime_max_move_duration:
			look_at(targetPlayer.global_position);
		var movementDirection = Vector2(cos(rotation), sin(rotation))
		translate(movementDirection * slime_move_speed * delta)
		slime_move_timer -= delta;
		if slime_move_timer <= 0:
			slime_cooldown_timer = slime_max_cooldown_duration
			slime_move_timer = slime_max_move_duration;
	else:
		slime_cooldown_timer -= delta;

func slimeNonPlayerMovement(delta):
	if slime_cooldown_timer <= 0:
		if slime_move_timer == slime_max_move_duration:
			rotation = rand_range(0, 2*PI);
		var movementDirection = Vector2(cos(rotation), sin(rotation))
		translate(movementDirection * slime_move_speed * delta)
		slime_move_timer -= delta;
		if slime_move_timer <= 0:
			slime_cooldown_timer = slime_max_cooldown_duration * 3
			slime_move_timer = slime_max_move_duration;
	else:
		slime_cooldown_timer -= delta;

func slime_on_death():
	get_tree().get_current_scene().spawn_loot_bag(position, process_loot());
	pass

func slime_on_damage(_damage_type, damage_value):
	health -= damage_value
	print(health)
	pass