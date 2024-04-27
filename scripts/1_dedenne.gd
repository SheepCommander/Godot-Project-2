extends RigidBody3D

@export var fruit_layer := 2
@export var next_fruit : PackedScene = load("res://scenes/2_sheep_derp.tscn")
@export var repeats := 0 ##How many times the Suika loop has repeated

@onready var collide_sfx := $CollideSFX
@onready var merge_sfx := $MergeSFX
@onready var merge_area : Area3D = $MergeArea
@onready var visibility_notifier = $VisibilityNotifier

func _ready():
	max_contacts_reported = 2
	contact_monitor = true
	merge_area.set_collision_mask_value(fruit_layer,true) #Listens for layer
	self.set_collision_layer_value(fruit_layer,true) #Fruit exists on layer
	
	body_entered.connect(_on_body_entered)
	visibility_notifier.screen_exited.connect(_on_visibility_notifier_screen_entered)

## Merges or plays SFX upon collission. See `_merge()`s
func _on_body_entered(_body): #On Collision
	var fruits := merge_area.get_overlapping_bodies()
	if fruits.size() >= 2:
		_merge(fruits)
		prints(self.name, fruits)
	else:
		collide_sfx.play()

## Kills all touching fruits of same-type, creates next fruit, plays `merge_sfx`
func _merge(fruits):
	var new_fruit := next_fruit.instantiate()
	get_tree().current_scene.add_child(new_fruit)
	
	new_fruit.global_position = (fruits[0].global_position+fruits[1].global_position)/2
	new_fruit.global_rotation = (fruits[0].global_rotation+fruits[1].global_rotation)/2
	new_fruit.repeats = repeats
	
	merge_sfx.play()
	
	fruits.map(func(body): body.queue_free())

## Kills fruit after leaving screen
func _on_visibility_notifier_screen_entered():
	print(name + " died")
	queue_free()
