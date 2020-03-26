extends RigidBody2D

var start_position;
var max_travel_distance;
var spawning_entity
var damage_type = "slashing"
var damage_value = 10

func _ready():
	linear_damp = 0;

func init(target_position:Vector2, target_angle:float, target_speed:float, target_range:float, lead_distance:float):
	start_position = target_position
	position = target_position;
	rotation = target_angle;
	position += Vector2(cos(target_angle), sin(target_angle)) * lead_distance
	linear_velocity = Vector2(cos(target_angle), sin(target_angle)) * target_speed;
	max_travel_distance = target_range
	pass

func _physics_process(_delta):
	if position.distance_to(start_position) > max_travel_distance:
		_end_of_life()

func _end_of_life():
	queue_free();

func _collision(body:Node2D):
	if body.is_in_group("Game_Entity"):
		body.recieve_damage(damage_value, damage_type)
	_end_of_life();

func _on_Projectile_body_entered(body):
	if body != spawning_entity:
		_collision(body);
