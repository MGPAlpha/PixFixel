class_name DownscaleTool extends ToolBase

func downscale_simple(img: Image, new_width: int, new_height: int) -> NewImageChangeDiff:
	
	var result = await downscale(img, new_width, new_height, 0, 0, 0, 0)
	return result

func downscale(img: Image, new_width: int, new_height: int,
	top_pad: float,
	right_pad: float,
	bottom_pad: float,
	left_pad: float):
		var new_size = Vector2(new_width, new_height)
		var original_size = Vector2(img.get_width(), img.get_height())
		original_size += Vector2(left_pad + right_pad, top_pad + bottom_pad)
		var viewport = SubViewport.new()
		viewport.size = Vector2i(new_width, new_height)
		viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		var camera = Camera2D.new()
		camera.zoom = new_size/original_size
		camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
		camera.position = Vector2(-left_pad, -top_pad)
		viewport.add_child(camera)
		var sprite = Sprite2D.new()
		sprite.centered = false
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

func analyze_for_smart_downscale(img: Image) -> Vector2i:
	return Vector2i.ZERO

func average(arr: Array[float]):
	var sum = 0
	for val: float in arr:
		sum += val
	return sum / arr.size()

# Returns a dictionary containing keys "a" and "b" as in y=a+bx
func linear_regression(x_arr: Array[float], y_arr: Array[float]) -> Dictionary:
	var x_bar = average(x_arr)
	var y_bar = average(y_arr)
	
	var num_sum = 0
	var den_sum = 0
	
	for i in x_arr.size():
		var delta_x = x_arr[i]-x_bar
		var delta_y = y_arr[i]-y_bar
		
		num_sum += delta_x*delta_y
		den_sum += delta_x*delta_x
	
	var b_hat = num_sum/den_sum
	var a_hat = y_bar - (b_hat * x_bar)
	var result = Dictionary()
	result["a"] = a_hat
	result["b"] = b_hat
	return result

# returns dictionary with regressions for keys "x" and "y"
func linear_regression_from_known_pixels(known_pixels: Array[InteractiveDownscalePixel]) -> Dictionary:
	var pixel_x_arr = Array([], TYPE_FLOAT, "", null)
	var pixel_y_arr = Array([], TYPE_FLOAT, "", null)
	var position_x_arr = Array([], TYPE_FLOAT, "", null)
	var position_y_arr = Array([], TYPE_FLOAT, "", null)
	
	for pixel in known_pixels:
		pixel_x_arr.append(float(pixel.pixel.x))
		pixel_y_arr.append(float(pixel.pixel.y))
		position_x_arr.append(pixel.position.x)
		position_y_arr.append(pixel.position.y)
		
	var x_regression = linear_regression(pixel_x_arr, position_x_arr)
	var y_regression = linear_regression(pixel_y_arr, position_y_arr)
	
	var result = Dictionary()
	result["x"] = x_regression
	result["y"] = y_regression
	return result

func estimate_pixel_index_from_position(position: Vector2, known_pixels: Array[InteractiveDownscalePixel]) -> Vector2i:
	var regressions = linear_regression_from_known_pixels(known_pixels)
	var pixel_x = (position.x - regressions["x"]["a"]) / regressions["x"]["b"]
	var pixel_y = (position.y - regressions["y"]["a"]) / regressions["y"]["b"]
	return Vector2i(round(pixel_x), round(pixel_y))
