extends RigidBody3D

@onready var collide_sfx := $CollideSFX


func _ready():
	name = get_parent().name
	max_contacts_reported = 100
	contact_monitor = true
	
	#merge_area.set_collision_mask_value(FRUIT_LAYER,true) #Listens for layer
	#self.set_collision_layer_value(FRUIT_LAYER,true) #Fruit exists on layer
	
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body): #On Collision
	collide_sfx.play()
	#get_tree().current_scene.call_deferred("add_child",new_fruit)
