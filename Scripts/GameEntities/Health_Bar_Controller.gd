extends Node2D

var _normal_dimensions
func _ready():
	_normal_dimensions = scale;
	get_parent().connect("health_update", self, "set_health")

func _physics_process(delta):
	correct_rotation()

func set_health(percentage:float):
	scale = Vector2(_normal_dimensions.x * percentage / 100,_normal_dimensions.y)
	pass

func correct_rotation():
	rotation = -get_parent().rotation