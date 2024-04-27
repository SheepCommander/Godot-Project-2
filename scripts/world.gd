extends Node3D

const fruits : Array[PackedScene] = [
	preload("res://scenes/1_dedenne.tscn"),
	preload("res://scenes/2_sheep_derp.tscn"),
	preload("res://scenes/3_sheep.tscn"),
]
@onready var spawn_location : PathFollow3D = $Floor/SpawnPath/SpawnLocation
@onready var spawn_timer := $SpawnTimer


func _ready():
	randomize()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()


func _on_spawn_timer_timeout():
	# Choose random fruit
	var new_fruit := fruits[randi() % fruits.size()].instantiate() #range[0,size-1]
	
	# Choose random point
	spawn_location.progress_ratio = randf()
	
	# Set fruit's position to the random location
	new_fruit.position = spawn_location.position
	
	# Set fruit's rotation
	new_fruit.rotation = spawn_location.rotation + Vector3(randf_range(-PI/4,PI/4),randf_range(-PI/4,PI/4),randf_range(-PI/4,PI/4))
