extends RigidBody2D

@export var FRUIT_NUMBER: int
@onready var merge_area : Area2D = $MergeArea
@onready var group := "Fruit%s" % FRUIT_NUMBER
@onready var next_fruit : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(group)
	max_contacts_reported = 100
	contact_monitor = true

	body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node):
	var same_fruits = merge_area.get_overlapping_bodies().filter(_is_in_same_group)
	if same_fruits.size() == 1:
		return #No fruits of the same type collided
	
	var bodies := same_fruits.size() + 0 #Include self!!
	print("%s says %s, %s" % [name,bodies,same_fruits])
	var avg_pos := global_position
	same_fruits.map(func(body): avg_pos += body.global_position)
	avg_pos /= bodies
	var avg_rotation := global_rotation
	same_fruits.map(func(body): avg_rotation += body.global_rotation)
	avg_rotation /= bodies
	print("%s, %s" % [avg_pos,avg_rotation])
	
	var new_fruit := next_fruit.instantiate()
	new_fruit.global_position = avg_pos
	new_fruit.global_rotation = avg_rotation
	get_tree().current_scene.call_deferred("add_child",new_fruit)
	
	same_fruits.map(func(body): body.queue_free())
	queue_free()

func _is_in_same_group(body) -> bool:
	print("%s - %s" % [body,is_in_group(group)])
	return body.is_in_group(group)

