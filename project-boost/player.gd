extends RigidBody3D

## How much vertical force to apply while moving
@export_range(750, 3000) var boost: int = 1000.0
@export var torque_trust: int = 100.0
var is_transitioning: bool = false
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * boost)
		booster_particles.emitting = true
		if rocket_audio.playing == false:
			rocket_audio.play()
	else:
		booster_particles.emitting = false
		rocket_audio.stop()
	
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_trust * delta))
		right_booster_particles.emitting = true
	else:
		right_booster_particles.emitting = false
	
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque_trust * delta))
		left_booster_particles.emitting = true
	else:
		left_booster_particles.emitting = false


func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		if "Ground" in body.get_groups():
			crash_sequence()

func crash_sequence() -> void:
	explosion_audio.play()
	explosion_particles.emitting = true
	set_process(is_transitioning)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)

func complete_level(next_level_file) -> void:
	success_audio.play()
	success_particles.emitting = true
	set_process(is_transitioning)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
