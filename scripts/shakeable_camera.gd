## Shakeable camera script. Requires CollisionShape3D and Camera as children.
## Call ScreenShakeCauser.cause_trauma() to apply trauma to camera.
class_name ShakeableCamera extends Area3D

@export var trauma_reduction_rate := 1.0 ##Trauma decreases by this amount every second.

@export var noise: FastNoiseLite = preload("res://resources/camera_shake_noise.tres") ##Changes feel of the shake. Experiment w/ Fractal however u want.
@export var noise_speed := 10.0
var time := 0.0

@export_group("Maximum Rotation")
@export var max_x := 75.0 ## Maximum degrees the camera can rotate on this axis
@export var max_y := 35.0 ## Maximum degrees the camera can rotate on this axis
@export var max_z := 35.0 ## Maximum degrees the camera can rotate on this axis

var trauma := 0.0 ##Intensity of shake. Decreases by reduc_rate every second. Range[0.0,1.0]

@onready var camera: Camera3D = $Camera
@onready var initial_rotation := camera.rotation_degrees ##Shake starts & end at camera's initial rotation.

func _process(delta: float) -> void: ##Applies camera shake.
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate,0.0)
	## Take initial rotation, use noise to add rotation between [-max,+max] * shake_intensity
	camera.rotation.x = initial_rotation.x + max_x * _get_shake_intensity() * _get_noise_from_seed(0)
	camera.rotation.y = initial_rotation.y + max_z * _get_shake_intensity() * _get_noise_from_seed(1)
	camera.rotation.z = initial_rotation.z + max_y * _get_shake_intensity() * _get_noise_from_seed(2)

func add_trauma(trauma_amount : float) -> void: ##Add trauma.
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

func _get_shake_intensity() -> float: ##Squares trauma, to create a exponential intensity ramp.
	return trauma * trauma

func _get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
