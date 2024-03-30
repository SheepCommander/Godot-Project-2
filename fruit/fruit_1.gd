extends RigidBody2D

@export var FruitNumber: int
@onready var merge_radius := $MergeRadius
@onready var fruit_inertia := 1.0 / PhysicsServer2D.body_get_direct_state(get_rid()).inverse_inertia

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Fruit"+str(FruitNumber))
	max_contacts_reported = 100
	contact_monitor = true
	
	body_entered.connect(_on_body_entered)
	
	# Give a random impulse lol
	print("start")
	await get_tree().create_timer(3).timeout
	print(fruit_inertia)
	apply_torque_impulse(500)
	#apply_torque_impulse(fruit_inertia * 0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_body_entered(body: Node):
	
	pass
