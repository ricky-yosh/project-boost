extends RigidBody3D

## How much vertical force to apply while moving
@export_range(750, 3000) var boost: int = 1000.0
@export var torque_trust: int = 100.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * boost)
	
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_trust * delta))
	
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque_trust * delta))


func _on_body_entered(body: Node) -> void:
	if "Goal" in body.get_groups():
		complete_level(body.file_path)
	if "Ground" in body.get_groups():
		crash_sequence()

func complete_level(next_level_file) -> void:
	get_tree().change_scene_to_file(next_level_file)

func crash_sequence() -> void:
	print("KABOOM!")
	get_tree().reload_current_scene()
