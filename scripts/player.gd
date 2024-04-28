extends CharacterBody3D ## From Lukky's 2023 FPS Controller Tut

# Player nodes
@onready var neck: Node3D = %Neck
@onready var head: Node3D = %Head
@onready var eyes: Node3D = %Eyes
@onready var standing_collision: CollisionShape3D = $standing_collision
@onready var crouching_collision: CollisionShape3D = $crouching_collision
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var camera_3d: Camera3D = %Camera3D
@onready var animation_player: AnimationPlayer = $Neck/Head/Eyes/AnimationPlayer

# Speed vars
var current_speed := 5.0
const walking_speed := 5.0
const sprinting_speed := 8.0
const crouching_speed := 3.0

# States
var walking := false
var sprinting := false
var crouching := false
var free_looking := false
var sliding := false

# Slide vars
var slide_timer := 0.0
var slide_timer_max := 1.0
var slide_vector := Vector2.ZERO
var slide_speed := 10

# Head bobbing vars
const head_bob_sprinting_speed := 22.0
const head_bob_walking_speed := 14.0
const head_bob_crouching_speed := 10.0

const head_bob_sprinting_intensity := 0.2
const head_bob_walking_intensity := 0.1
const head_bob_crouching_intensity := 0.05

var head_bob_current_intensity := 0.0
var head_bob_vector := Vector2.ZERO
var head_bob_index := 0.0 ## The value plugged into the head bobbing sin function

# Movement vars
var crouching_depth := -0.8

const jump_velocity := 4.5

const lerp_speed := 10.0 ##Lerp speed for both movement & camera
const air_lerp_speed := 3.0

var free_look_tilt_amount := 10 ## Camera tilt while free-looking, in degrees.

var last_velocity := Vector3.ZERO

# Input vars
var direction := Vector3.ZERO
const mouse_sens := 0.2

# Gravity
var gravity := 9.8

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	## Mouse looking logic
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y,deg_to_rad(-120),deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))

func _physics_process(delta: float) -> void:
	# Getting movement input
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	
	# Handle movement STATES
	## Crouching
	if Input.is_action_pressed("Crouch") or sliding:
		
		current_speed = lerp(current_speed, crouching_speed, delta*lerp_speed)
		head.position.y = lerp(head.position.y, crouching_depth, delta*lerp_speed)
		
		standing_collision.disabled = true
		crouching_collision.disabled = false
		
		## Slide begin logic
		if sprinting and input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
			print("Slide begin")
		
		walking = false
		sprinting = false
		crouching = true
	
	elif not ray_cast_3d.is_colliding():
		## Standing
		standing_collision.disabled = false
		crouching_collision.disabled = true
		
		head.position.y = lerp(head.position.y, 0.0, delta*lerp_speed)
		
		if Input.is_action_pressed("Sprint"):
			## Sprinting
			current_speed = lerp(current_speed, sprinting_speed, delta*lerp_speed)
			
			walking = false
			sprinting = true
			crouching = false
		else:
			## Walking
			current_speed = lerp(current_speed, walking_speed, delta*lerp_speed)
			
			walking = true
			sprinting = false
			crouching = false
	
	## Handle freelooking
	if Input.is_action_pressed("free_look") or sliding:
		free_looking = true
		if sliding: #Sliding rotation: Little
			eyes.rotation.z = lerp(eyes.rotation.z, deg_to_rad(7.0), delta*lerp_speed)
		else: #Normal rotation: Over the shoulder
			eyes.rotation.z = deg_to_rad(neck.rotation.y * free_look_tilt_amount)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta*lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta*lerp_speed)
	
	## Handle sliding
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			print("Slide ends")
			free_looking = false
	
	## Handle headbob
	if sprinting:
		head_bob_current_intensity = head_bob_sprinting_intensity
		head_bob_index += head_bob_sprinting_speed * delta
	elif walking:
		head_bob_current_intensity = head_bob_sprinting_intensity
		head_bob_index += head_bob_walking_speed * delta
	elif crouching:
		head_bob_current_intensity = head_bob_crouching_intensity
		head_bob_index += head_bob_crouching_speed * delta
	
	if is_on_floor() and not sliding and input_dir != Vector2.ZERO:
		head_bob_vector.y = sin(head_bob_index)
		head_bob_vector.x = sin(head_bob_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bob_vector.y*(head_bob_current_intensity/2.0), delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bob_vector.x*head_bob_current_intensity, delta*lerp_speed)
	else:
		eyes.position.x = lerp(eyes.position.x, 0.0, delta*lerp_speed)
		eyes.position.y = lerp(eyes.position.y, 0.0, delta*lerp_speed)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	## Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		sliding = false
		animation_player.play("Jump")
	
	# Handle landing
	if is_on_floor():
		if last_velocity.y < -10.0:
			animation_player.play("Roll")
		elif last_velocity.y < -4.0:
			animation_player.play("Landing")
			print(last_velocity.y)
	
	# Get the input direction and handle the movement/deceleration.
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*(air_lerp_speed))
	
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.1) * slide_speed
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	last_velocity = velocity
	
	move_and_slide()
	
