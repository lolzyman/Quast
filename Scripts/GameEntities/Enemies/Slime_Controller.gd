extends Base_Enemy

export (float) var slime_max_cooldown_duration = 0.5; 
var slime_cooldown_timer = 0;
export (float) var slime_max_move_duration = .125;
var slime_move_timer = 0;
export (float) var slime_move_speed = 300;
export (PackedScene) var smaller_slime
export (float) var smaller_slime_probability
export (float) var smaller_slime_quantity
export (float) var smaller_slime_spawn_radius = 50
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
	if smaller_slime != null:
		print("trying to spawn smaller slimes")
		var slime_quantity = 0;
		for x in range(smaller_slime_quantity):
			var rand_number = rand_range(0, 99);
			print(rand_number);
			if rand_number < smaller_slime_probability:
				slime_quantity += 1;
		print(slime_quantity);
		if(slime_quantity != 0):
			var current_spawn_vector = Vector2(0,smaller_slime_spawn_radius).rotated(rand_range(0,2*PI));
			var spawn_seperation_angle = 2*PI/slime_quantity;
			for x in range(slime_quantity):
				var new_slime = smaller_slime.instance();
				new_slime.position = position + current_spawn_vector;
				current_spawn_vector = current_spawn_vector.rotated(spawn_seperation_angle)
				print(spawn_seperation_angle, current_spawn_vector)
				get_parent().add_child(new_slime);
	get_tree().get_current_scene().spawn_loot_bag(position, process_loot());
	pass

func slime_on_damage(_damage_type, damage_value):
	health -= damage_value
	print(health)
	pass
