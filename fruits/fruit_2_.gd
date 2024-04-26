extends Node2D


func _ready():
	var rigid_body := $RigidBody2D
	prints(get_children())
	get_children().map(func(node: Node): if node != rigid_body: node.reparent(rigid_body))
