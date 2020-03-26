extends "res://Scripts/GameEntities/Enemies/EnemyController.gd"

# Variables that are accessible
# targetPlayer

func _ready():
	var _err = self.connect("playerMovement", self, "___PlayerMovement");
	_err = self.connect("nonPlayerMovement", self, "___NonPlayerMovement");
	_err = connect("recieve_damage", self,"___on_damage");
	_err = connect("on_death", self, "___on_death");

func ___PlayerMovement(_delta):
	pass

func ___NonPlayerMovement(_delta):
	pass

func ___on_death():
	get_tree().get_current_scene().spawn_loot_bag(position);
	pass

func ___on_damage(_damage_type, _damage_value):
	pass