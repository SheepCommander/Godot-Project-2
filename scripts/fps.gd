extends Label

func _process(delta: float) -> void:
	text = "Current FPS: %d" % Engine.get_frames_per_second()
	#Engine.max_fps = 60
