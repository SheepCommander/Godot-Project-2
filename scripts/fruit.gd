extends RigidBody3D
class_name Fruit

const fruit_list : Array[PackedScene] = [
	preload("res://scenes/1_dedenne.tscn"),
	preload("res://scenes/2_sheep_derp.tscn"),
	preload("res://scenes/3_sheep.tscn"),
	preload("res://scenes/4_ozi.tscn"),
	preload("res://scenes/5_earless.tscn"),
]
const in_use_physics_layers := 1 ## IMPORTANT: SET TO NUM OF NON-FRUIT PHYSICS LAYERS
const scale_increase := 0.5
var repeats := 0 ##How many times the Suika loop has repeated
@export var fruit_index := 1 ## Start from 1
@onready var next_fruit : PackedScene = fruit_list[(fruit_index) % fruit_list.size()]
#SFX
@onready var collide_sfx := $CollideSFX
@onready var merge_sfx := $MergeSFX
#Areas
@onready var merge_area : Area3D = $MergeArea
@onready var visibility_notifier = $VisibilityNotifier

func _ready():
	scale = Vector3(1+(repeats*scale_increase),1+(repeats*scale_increase),1+(repeats*scale_increase))
	max_contacts_reported = 2
	contact_monitor = true
	merge_area.set_collision_mask_value(fruit_index + in_use_physics_layers,true) #Listens for layer
	self.set_collision_layer_value(fruit_index + in_use_physics_layers,true) #Fruit exists on layer
	
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
	print(next_fruit.instantiate())
	var fruit : Fruit = next_fruit.instantiate()
	get_tree().current_scene.add_child(fruit)
	fruit.global_position = (fruits[0].global_position+fruits[1].global_position)/2
	fruit.global_rotation = (fruits[0].global_rotation+fruits[1].global_rotation)/2
	
	fruit.set_repeats(repeats)
	
	if next_fruit == fruit_list[0]: fruit.repeats += 1
	merge_sfx.play()
	
	fruits.map(func(body): body.queue_free())

## Kills fruit after leaving screen
func _on_visibility_notifier_screen_entered():
	print(name + " died")
	queue_free()

## Repeats
func set_repeats(x: int):
	repeats = x
