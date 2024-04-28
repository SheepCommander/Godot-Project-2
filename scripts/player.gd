class_name Player extends CharacterBody3D

signal jumped(bool)
signal dash_complete(bool)
signal got_pounded(float)
var speed : float = 12.0

@export var max_jumps : int = 2
@export var jump_strength = 10.8
@export var slide_speed : float = 20.0

var jump_amount : int = 0
const SENSITIVITY = 0.04

var air_lerp_speed : float = 3.0
var ground_lerp_speed : float = 8.0

#bob variables
const BOB_FREQ = 2.3
const BOB_AMP = 0.035
var t_bob = 0.0

var gravity = 9.8
var direction
@onready var cam_position = $CamPosition
@onready var cam_rot = $CamPosition/CamRot
@onready var cam_pivot = $CamPosition/CamRot/CamPivot
@onready var camera = %Camera

var can_foot : bool = false
var sliding : bool = false
var climbing : bool = false
var grabbing : bool = false
var pounding : bool = false
var climb_amount : int = 0
var gravity_allowed : bool = true
var pound_speed : float = 15.0
var pound_timer : float = 0.0
var slide_timer : float = 5.0
var slide_direction : Vector3
var jump_timer : float = 1.0
var default_cam_position : Vector3
var real := false

#@onready var standing_collision = $"StandingCollision"

func _ready():
	default_cam_position = cam_position.position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
		cam_rot.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))
		cam_rot.rotation.x = clamp(cam_rot.rotation.x, deg_to_rad(-85), deg_to_rad(85))


func _process(delta):
	if is_on_floor():
		if pounding:
			got_pounded.emit(pound_timer)
			#if pound_timer >= 0.2:
				#$Sounds/Pound.play()
			pound_timer = 0.0
			pounding = false
		jump_amount = max_jumps

	if !is_on_floor() and !grabbing:
		if not pounding:
			velocity.y -= gravity * delta * 5.0
		else:
			velocity.y -= gravity * delta * 5.0 * pound_speed

	if Input.is_action_just_pressed('Pound'):
		pounding = true

	if pounding:
		pound_timer += delta

	if Input.is_action_just_pressed("Jump"):
		jump(true)

	if Input.is_action_just_released('Jump'):
		jump(false)

	if not gravity_allowed:
		if velocity.y < 0.0:
			velocity.y = lerp(velocity.y,0.0,20.0 * delta)

	if air_lerp_speed >= 15.0:
		velocity.y = lerp(velocity.y,0.0,air_lerp_speed * delta)

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor() and !grabbing:
		if direction:
			velocity.x = lerp(velocity.x,direction.x * speed, ground_lerp_speed * delta)
			velocity.z = lerp(velocity.z,direction.z * speed, ground_lerp_speed * delta)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * ground_lerp_speed)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * ground_lerp_speed)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * air_lerp_speed)
		if velocity.y > jump_strength:
			velocity.y = lerp(velocity.y,jump_strength, 4.5 * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * air_lerp_speed)

	air_lerp_speed = lerp(air_lerp_speed,3.0,5 * delta)
	ground_lerp_speed = lerp(air_lerp_speed,3.0,5 * delta)

	# Head bob
	if is_on_floor() and !sliding:
		t_bob += delta * velocity.length() * float(is_on_floor())
		cam_pivot.transform.origin = _headbob(t_bob)

	if Input.is_action_pressed("Slide") and is_on_floor() and !sliding:
		if input_dir:
			slide_direction = direction
		else:
			slide_direction = (transform.basis * Vector3(0, 0, -1)).normalized()
		sliding = true
		slide_timer = 1.0
		#$Sounds/Slide.play()
	if Input.is_action_just_released('Slide') and sliding:
		sliding = false

	cam_position.position = lerp(cam_position.position,Vector3(0,default_cam_position.y,0),5 * delta)

	if real:
		velocity.y = lerp(velocity.y,0.0,25.0 * delta)

	if climbing and climb_amount > 0:
		velocity.y = 10
	if sliding:
		slide(delta)


	move_and_slide()

func slide(delta):
	cam_position.position = lerp(cam_position.position,Vector3(0,default_cam_position.y - 0.6,0),15 * delta)
	velocity.x = slide_direction.x * slide_speed * (slide_timer + 0.1)
	velocity.z = slide_direction.z * slide_speed * (slide_timer + 0.1)
	slide_timer -= delta

	if Input.is_action_just_pressed("Jump"):
		velocity.x += slide_direction.x * slide_speed
		velocity.z += slide_direction.z * slide_speed
	if slide_timer <= 0.0:
		sliding = false

func jump(real : bool):
	climbing = real
	if real:
		if jump_amount > 0:
			#$Sounds/Jump.play()
			jump_amount -= 1
			velocity.y = jump_strength
			velocity.x += speed * direction.x * 2
			velocity.z += speed * direction.z * 2
			slide_timer = 0.0

func _headbob(time) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	if pos.y >= (BOB_AMP * 0.8):
		can_foot = true

	if can_foot and pos.y <= (BOB_AMP * -0.8):
		can_foot = false
		#$Sounds/Footstep.play()

	return pos

#func disable_collision():
	#standing_collision.disabled = true

#func enable_collision():
	#standing_collision.disabled = false

func dashment(friction : float):
	ground_lerp_speed = friction
	air_lerp_speed = friction
