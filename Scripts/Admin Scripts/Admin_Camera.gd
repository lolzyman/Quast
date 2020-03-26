extends Camera2D
export var camera_speed = 50;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	var moving_left = Input.is_action_pressed("ui_left");
	var moving_right = Input.is_action_pressed("ui_right")
	var moving_up = Input.is_action_pressed("ui_up")
	var moving_down = Input.is_action_pressed("ui_down")
	var fine_resolution = Input.is_action_pressed("game_fine_resolution")
	var deltaX = 0;
	var deltaY = 0;
	var fine_resolution_multiplier = 1
	if fine_resolution:
		fine_resolution_multiplier = 0.5
	if(moving_left):
		deltaX -= _delta * camera_speed * fine_resolution_multiplier
	if moving_right:
		deltaX += _delta * camera_speed * fine_resolution_multiplier
	if moving_up:
		deltaY -= _delta * camera_speed * fine_resolution_multiplier
	if moving_down:
		deltaY += _delta * camera_speed * fine_resolution_multiplier
	position = Vector2(position.x + deltaX, position.y + deltaY)
	