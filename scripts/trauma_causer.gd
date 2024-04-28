## Causes trauma_amount trauma to all overlapping ShakeableCamera when cause_trauma() is called.
## Requiers CollisionShape3D as child.
class_name ScreenShakeCauser extends Area3D

@export_range(0.0,1.0) var trauma_amount := 0.1 ## The amount of trauma to apply.

func cause_trauma(): ## Applies trauma_amount to all overlapping ShakeableCamera
	var trauma_areas := get_overlapping_areas()
	for area : Area3D in trauma_areas:
		if area.has_method("add_trauma"):
			area.add_trauma(trauma_amount)
