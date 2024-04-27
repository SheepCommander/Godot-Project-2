extends RigidBody3D

@export var fruit_layer := 2
@export var next_fruit := preload("res://scenes/1_dedenne.tscn")
@onready var collide_sfx := $CollideSFX
@onready var merge_area : Area3D = $MergeArea

func _ready():
	max_contacts_reported = 100
	contact_monitor = true
	
	merge_area.set_collision_mask_value(fruit_layer,true) #Listens for layer
	self.set_collision_layer_value(fruit_layer,true) #Fruit exists on layer
	
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body): #On Collision
	collide_sfx.play()
	
	var fruits := merge_area.get_overlapping_bodies()
	if fruits.size() <= 1: return
	prints(self.name, fruits)
	
	var new_fruit := next_fruit.instantiate()
	new_fruit.global_position = (fruits[0].global_position+fruits[1].global_position)/2
	new_fruit.global_rotation = (fruits[0].global_rotation+fruits[1].global_rotation)/2
	get_tree().current_scene.call_deferred("add_child",new_fruit)
	
	fruits.map(func(body): body.queue_free())
