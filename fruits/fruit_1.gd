extends RigidBody2D

@onready var merge_area : Area2D = $MergeArea
@export var FRUIT_LAYER := 2 ## Check the collision layers!
@export var next_fruit : PackedScene = preload("res://fruits/fruit_2_.tscn")

func _ready():
	max_contacts_reported = 100
	contact_monitor = true
	
	merge_area.set_collision_mask_value(FRUIT_LAYER,true) #Listens for layer
	self.set_collision_layer_value(FRUIT_LAYER,true) #Fruit exists on layer
	
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body): #On Collision
	var fruits := merge_area.get_overlapping_bodies()
	if fruits.size() <= 1:
		return
	prints(self.name, fruits)
	
	#var avg_pos := Vector2(0,0)
	#fruits.map(func(body): avg_pos += body.global_position)
	#avg_pos /= fruits.size()
	#var avg_rotation := 0.0
	#fruits.map(func(body): avg_rotation += body.global_rotation)
	#avg_rotation /= fruits.size()
	
	var new_fruit := next_fruit.instantiate()
	new_fruit.global_position = global_position
	new_fruit.global_rotation = global_rotation
	get_tree().current_scene.call_deferred("add_child",new_fruit)
	
	fruits.map(func(body): body.queue_free())
