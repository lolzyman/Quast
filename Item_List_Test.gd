extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (NodePath) var targetCameraPath
var targetCamera
# Called when the node enters the scene tree for the first time.
func _ready():
	targetCamera = get_node(targetCameraPath)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var motion = Vector2();
	var SPEED = 5;
	if Input.is_action_pressed("ui_right"):
		motion.x = SPEED;
	elif Input.is_action_pressed("ui_left"):
		motion.x = -SPEED;
	else:
		motion.x = 0;
	if Input.is_action_pressed("ui_up"):
		motion.y = -SPEED;
	elif Input.is_action_pressed("ui_down"):
		motion.y = SPEED;
	else:
		motion.y = 0;
	targetCamera.position += motion;
	print(targetCamera.position)
