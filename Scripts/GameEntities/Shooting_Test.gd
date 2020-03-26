extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var cooldownTimer;
var projectile_shoot_range = 1000;
var projectile_shoot_speed = 100;
export (PackedScene) var projectile;

func _ready():
	cooldownTimer = Timer.new()
	cooldownTimer.connect("timeout", self, "shooter")
	cooldownTimer.start(1);
	add_child(cooldownTimer)

func shooter():
	shoot(self)

func shoot(targetParent):
	var spawned_projectile = projectile.instance();
	spawned_projectile.init(position, rotation, projectile_shoot_speed, projectile_shoot_range);
	targetParent.add_child(spawned_projectile);

func _physics_process(_delta):
	look_at(get_global_mouse_position());