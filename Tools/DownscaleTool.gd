class_name DownscaleTool extends ToolBase

func downscale_simple(img: Image, new_width: int, new_height: int) -> NewImageChangeDiff:
	var new_size = Vector2(new_width, new_height)
	var original_size = Vector2(img.get_width(), img.get_height())
	var viewport = SubViewport.new()
	viewport.size = Vector2i(new_width, new_height)
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	var camera = Camera2D.new()
	camera.zoom = new_size/original_size
	viewport.add_child(camera)
	var sprite = Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	viewport.add_child(sprite)
	(Engine.get_main_loop() as SceneTree).root.add_child(viewport)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var newImage = viewport.get_texture().get_image()
	var result = NewImageChangeDiff.new(img, newImage)
	viewport.queue_free()
	return result
