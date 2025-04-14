class_name InteractiveDownscaleGizmo extends Node2D

@export var drag_handle_range = 5

signal add_known_pixel(pos: Vector2)
signal pixel_dragged(index: int, pixel: InteractiveDownscalePixel)

var curr_image: Image = null

var known_pixels: Array[InteractiveDownscalePixel]

var dragging = false
var drag_index = -1



func update_pixels(pixels: Array[InteractiveDownscalePixel]):
	known_pixels = pixels

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _draw() -> void:
	var world_to_screen_transform = get_viewport().get_camera_2d().get_canvas_transform()
	var half_img_size = Vector2(curr_image.get_size())/2
	var size_factor = get_viewport_transform().get_scale().x
	for i in known_pixels.size():
		var drag_handle_screen_pos = (known_pixels[i].position - half_img_size)
		draw_circle(drag_handle_screen_pos, 4/size_factor, Color.BLACK)
		draw_circle(drag_handle_screen_pos, 3/size_factor, Color.ORANGE)


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
