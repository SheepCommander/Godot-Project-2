extends Control

@onready var texture_rect := $TextureRect
@onready var animation_player := $AnimationPlayer

@export_enum("Slide","Spin","Fade") var animation := "Slide"
#TODO:
#HACK:
#FIXME:
func _ready():
	for i in range(3):
		await get_tree().create_timer(1).timeout
		slide()
		await get_tree().create_timer(1).timeout
		spin()
		await get_tree().create_timer(1).timeout
		fade()

func _get_screenshot():
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	texture_rect.texture = ImageTexture.create_from_image(img)
	texture_rect.pivot_offset = texture_rect.size/2

func slide():
	await _get_screenshot()
	animation_player.play("Slide")

func spin():
	await _get_screenshot()
	animation_player.play("Spin")

func fade():
	await _get_screenshot()
	animation_player.play("Fade")
