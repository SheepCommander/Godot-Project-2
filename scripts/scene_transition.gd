extends Control

@onready var texture_rect := $TextureRect
@onready var animation_player := $AnimationPlayer

#TODO: Make transitions actually... useful???
@export_enum("Slide","Spin","Fade","Dissolve") var animation := "Slide"

func _ready():
	play(animation)


func _get_screenshot(flip_x := false,flip_y := false):
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if flip_x: img.flip_x()
	if flip_y: img.flip_y()
	texture_rect.texture = ImageTexture.create_from_image(img)
	texture_rect.pivot_offset = get_viewport().size/2


func play(animation:String,flip_x := false,flip_y := false):
	await _get_screenshot(flip_x,flip_y)
	texture_rect.show()
	animation_player.play(animation)
	await animation_player.animation_finished
	texture_rect.hide()
