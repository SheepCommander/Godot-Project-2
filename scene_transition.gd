extends Control

@onready var texture_rect := $TextureRect
@onready var animation_player := $AnimationPlayer

@export_enum("Slide","Spin","Fade") var animation := "Slide"

func _ready():
	for i in range(5):
		await get_tree().create_timer(1).timeout
		slide()
		await get_tree().create_timer(1).timeout
		spin()

func _get_screenshot() -> ImageTexture:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	return ImageTexture.create_from_image(img)

func slide():
	texture_rect.texture = await _get_screenshot()
	animation_player.play("Slide")

func spin():
	texture_rect.texture = await _get_screenshot()
	animation_player.play("Spin")
