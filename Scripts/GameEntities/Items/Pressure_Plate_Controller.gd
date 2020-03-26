extends Area2D
export (Array, NodePath) var affected_entites
export (Array, NodePath) var connected_plates
enum possible_states {UNTRIGGERED, TRIGGERED}
var my_state = possible_states.UNTRIGGERED
var pressure_plate_unique_id;

signal plate_triggered

func _ready():
	add_to_group("Trigger_Plate");
	pressure_plate_unique_id = globals.pressure_plate_states.size()
	globals.pressure_plate_states.push_back([self.get_path(), my_state]);
func _pressure_plate_triggered(_body):
	activate_trigger()
func activate_trigger():
	if(my_state == possible_states.UNTRIGGERED):
		my_state = possible_states.TRIGGERED
		for pathToTartget in affected_entites:
			var targetEntity = get_node(pathToTartget)
			if targetEntity != null:
				targetEntity.queue_free()
		emit_signal("plate_triggered")
func _connect_to_other_plates():
	for pathToTarget in connected_plates:
		var targetPlate = get_node(pathToTarget)
		if targetPlate != null:
			var _err = connect("plate_triggered", targetPlate, "activate_trigger")
	pass