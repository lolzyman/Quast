extends "res://Scripts/GameEntities/Enemies/EnemyController.gd"

# Variables that are accessible
# targetPlayer

#Add system to stop bat movement when it is close to a point for returning home

var bat_current_velocity : Vector2 = Vector2(0,0)
var bat_target_player_vector : Vector2 = Vector2(0,0)
var bat_speed = 25;
var bat_maxspeed = 400;
var home_position;

func _ready():
	var _err = self.connect("playerMovement", self, "batPlayerMovement");
	_err = self.connect("nonPlayerMovement", self, "batNonPlayerMovement");
	linear_damp = 1;
	home_position = position;

func batPlayerMovement(_delta):
	#here the AI controller controlls the player
	var target_position = targetPlayer.position
	bat_target_player_vector = (target_position - position).normalized();
	bat_current_velocity = linear_velocity;
	var bat_new_velocity = bat_current_velocity + bat_target_player_vector * bat_speed
	if bat_new_velocity.length() < bat_maxspeed:
		bat_current_velocity = bat_new_velocity;
	linear_velocity = bat_current_velocity
	print(targetPlayer)

func batNonPlayerMovement(_delta):
	#The bat is going to return back to the place where it started.
	#Eventually The Bat animation will change but movement will need to be completed first
	bat_target_player_vector = (home_position - position).normalized();
	bat_current_velocity = linear_velocity;
	var bat_new_velocity = bat_current_velocity + bat_target_player_vector * bat_speed
	if bat_new_velocity.length() < bat_maxspeed:
		bat_current_velocity = bat_new_velocity;
	linear_velocity = bat_current_velocity