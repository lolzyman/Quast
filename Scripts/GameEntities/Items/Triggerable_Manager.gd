extends Node2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var all_children = get_children();
	var all_trigger_plates = [];
	var all_false_doors = [];
	for child in all_children:
		if child.is_in_group("Trigger_Plate"):
			all_trigger_plates.push_back(child);
		if child.is_in_group("False_Wall"):
			all_false_doors.push_back(child);
	for trigger_plate in all_trigger_plates:
		for false_door in all_false_doors:
			trigger_plate.affected_entites.push_back(false_door.get_path());

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
