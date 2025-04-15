class_name InteractiveDownscaleGizmo extends Node2D

@export var drag_handle_range = 5

signal add_known_pixel(pos: Vector2)
signal pixel_dragged(index: int, pixel: InteractiveDownscalePixel)

var curr_image: Image = null

var known_pixels: Array[InteractiveDownscalePixel]

var dragging = false
var drag_index = -1

var min_x = INF
var max_x = -INF
var min_y = INF
var max_y = -INF

func update_pixels(pixels: Array[InteractiveDownscalePixel]):
	known_pixels = pixels
	min_x = INF
	max_x = -INF
	min_y = INF
	max_y = -INF
	for pixel in known_pixels:
		min_x = min(min_x, pixel.position.x) 
		max_x = max(max_x, pixel.position.x) 
		min_y = min(min_y, pixel.position.y) 
		max_y = max(max_y, pixel.position.y) 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _draw() -> void:
	
	var img_width = curr_image.get_width()
	var img_height = curr_image.get_height()
	
	var world_to_screen_transform = get_viewport().get_camera_2d().get_canvas_transform()
	var half_img_size = Vector2(curr_image.get_size())/2
	var size_factor = get_viewport_transform().get_scale().x
	for i in known_pixels.size():
		var drag_handle_screen_pos = (known_pixels[i].position - half_img_size)
		draw_circle(drag_handle_screen_pos, 4/size_factor, Color.BLACK)
		draw_circle(drag_handle_screen_pos, 3/size_factor, Color.ORANGE)
		
	if known_pixels.size() > 1:		
		var known_x_span = max_x - min_x
		var known_y_span = max_y - min_y
		var safe_x_max = max_x + known_x_span
		var safe_y_max = max_y + known_y_span
		var safe_x_min = min_x - known_x_span
		var safe_y_min = min_y - known_y_span
		safe_x_max = min(safe_x_max, curr_image.get_width())
		safe_y_max = min(safe_y_max, curr_image.get_height())
		safe_x_min = max(safe_x_min, 0)
		safe_y_min = max(safe_y_min, 0)
		
		var unsafe_zone_color = Color(0,0,0,.5)
		if safe_x_min > 0:
			draw_rect(Rect2(0 - img_width/2, safe_y_min - img_height/2, safe_x_min, safe_y_max - safe_y_min), unsafe_zone_color)
		if safe_y_min > 0:
			draw_rect(Rect2(0 - img_width/2, 0 - img_height/2, img_width, safe_y_min), unsafe_zone_color)
		if safe_x_max < img_width:
			draw_rect(Rect2(safe_x_max - img_width/2, safe_y_min - img_height/2, img_width - safe_x_max, safe_y_max - safe_y_min), unsafe_zone_color)
		if safe_y_max < img_height:
			draw_rect(Rect2(0 - img_width/2, safe_y_max - img_height/2, img_width, img_height - safe_y_max), unsafe_zone_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var handle = _find_drag_handle_in_range(event.position)
				if handle > -1:
					dragging = true
					drag_index = handle
					get_viewport().set_input_as_handled()
					print("now dragging handle ", handle)
				else:
					var world_pos = get_viewport().get_camera_2d().get_canvas_transform().affine_inverse() * event.position + Vector2(curr_image.get_size())/2
					add_known_pixel.emit(world_pos)
			else:
				if dragging:
					dragging = false
					drag_index = -1
					print("released")
					get_viewport().set_input_as_handled()
					
	if event is InputEventMouseMotion and dragging:
		if drag_index >= 0:
			var world_pos = get_viewport().get_camera_2d().get_canvas_transform().affine_inverse() * event.position
			var updated_pixel = known_pixels[drag_index]
			updated_pixel.position = world_pos + Vector2(curr_image.get_size())/2
			pixel_dragged.emit(drag_index, updated_pixel)
			get_viewport().set_input_as_handled()


func _find_drag_handle_in_range(screen_pos: Vector2) -> int:
	var world_to_screen_transform = get_viewport().get_camera_2d().get_canvas_transform()
	var half_img_size = Vector2(curr_image.get_size())/2
	for i in known_pixels.size():
		var drag_handle_screen_pos = world_to_screen_transform * (known_pixels[i].position - half_img_size)
		var diff = drag_handle_screen_pos - screen_pos
		if abs(diff.x) <= drag_handle_range and abs(diff.y) <= drag_handle_range:
			return i
	return -1
