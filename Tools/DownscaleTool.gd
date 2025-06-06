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
		var result = NewImageChangeDiff.new("Downscale", img, newImage)
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
	var pixel_x = eval_regression_inverse(regressions["x"], position.x)
	var pixel_y = eval_regression_inverse(regressions["y"], position.y)
	return Vector2i(round(pixel_x), round(pixel_y))

func eval_regression(reg: Dictionary, x: float) -> float:
	return reg["b"] * x + reg["a"]

func eval_regression_inverse(reg: Dictionary, y: float) -> float:
	return (y - reg["a"]) / reg["b"]

func downscale_interactive(img: Image, known_pixels: Array[InteractiveDownscalePixel]) -> NewImageChangeDiff:
	var img_dim = img.get_size()
	var img_width = img_dim.x
	var img_height = img_dim.y
	var regressions = linear_regression_from_known_pixels(known_pixels)
	var x_reg = regressions["x"]
	var y_reg = regressions["y"]
	
	var min_pixel_x = ceil(eval_regression_inverse(x_reg, 0)) - .5
	var min_pixel_y = ceil(eval_regression_inverse(y_reg, 0)) - .5
	var max_pixel_x = floor(eval_regression_inverse(x_reg, img_width)) + .5
	var max_pixel_y = floor(eval_regression_inverse(y_reg, img_height)) + .5
	
	var downscale_width = max_pixel_x - min_pixel_x
	var downscale_height = max_pixel_y - min_pixel_y
	
	var pad_top = eval_regression(y_reg, min_pixel_y)
	var pad_left = eval_regression(x_reg, min_pixel_x)
	var pad_right = img_width - eval_regression(x_reg, max_pixel_x)
	var pad_bottom = img_height - eval_regression(y_reg, max_pixel_y)
	
	return await downscale(img, downscale_width, downscale_height, -pad_top, -pad_right, -pad_bottom, -pad_left)
