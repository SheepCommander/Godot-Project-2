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


func _on_spawn_timer_timeout():
	var new_fruit := fruits[randi() % fruits.size()].instantiate() #Random Fruit

	spawn_location.progress_ratio = randf() #Random point
	new_fruit.position = spawn_location.position #To that position
	new_fruit.rotation = spawn_location.rotation + Vector3(randf_range(-PI/4,PI/4),randf_range(-PI/4,PI/4),randf_range(-PI/4,PI/4))

	add_child(new_fruit) #Spawn mob

