class_name CropToolGizmo extends Node2D

@export var drag_handle_range = 5

signal top_adjusted(pos: int)
signal right_adjusted(pos: int)
signal bottom_adjusted(pos: int)
signal left_adjusted(pos: int)
signal adjustment_complete

var curr_image: Image = null

class DragHandle extends RefCounted:
	var position: Vector2
	var adjust_top: bool
	var adjust_right: bool
	var adjust_bottom: bool
	var adjust_left: bool
	
	func _init(top: bool, right: bool, bottom: bool, left: bool):
		adjust_top = top
		adjust_right = right
		adjust_bottom = bottom
		adjust_left = left

var top_right = DragHandle.new(true, true, false, false)
var bottom_right = DragHandle.new(false, true, true, false)
var bottom_left = DragHandle.new(false, false, true, true)
var top_left = DragHandle.new(true, false, false, true)

var top = DragHandle.new(true, false, false, false)
var right = DragHandle.new(false, true, false, false)
var bottom = DragHandle.new(false, false, true, false)
var left = DragHandle.new(false, false, false, true)

var corners : Array[DragHandle] = [top_right, bottom_right, bottom_left, top_left]
var sides : Array[DragHandle] = [right, bottom, left, top]

var drag_handles: Array[DragHandle] = [top_right, bottom_right, bottom_left, top_left, top, bottom, left, right]

var dragging: bool = false
var curr_handle: DragHandle = null

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_line(corners[0].position, corners[1].position, Color.ORANGE)
	draw_line(corners[1].position, corners[2].position, Color.ORANGE)
	draw_line(corners[2].position, corners[3].position, Color.ORANGE)
	draw_line(corners[3].position, corners[0].position, Color.ORANGE)
	
	var size_factor = get_viewport_transform().get_scale().x
	
	draw_circle(corners[0].position, 5/size_factor, Color.ORANGE)
	draw_circle(corners[1].position, 5/size_factor, Color.ORANGE)
	draw_circle(corners[3].position, 5/size_factor, Color.ORANGE)
	draw_circle(corners[2].position, 5/size_factor, Color.ORANGE)
	
	draw_circle(sides[0].position, 5/size_factor, Color.ORANGE)
	draw_circle(sides[1].position, 5/size_factor, Color.ORANGE)
	draw_circle(sides[3].position, 5/size_factor, Color.ORANGE)
	draw_circle(sides[2].position, 5/size_factor, Color.ORANGE)
	
func update_positions(top: int, left: int, right: int, bottom: int, img: Image):
	curr_image = img
	var width = float(img.get_width())
	var height = float(img.get_height())
	while corners.size() < 4:
		corners.append(Vector2.ZERO)
	corners[0].position = Vector2(width/2-right, -height/2+top)
	corners[1].position = Vector2(width/2-right, height/2-bottom)
	corners[2].position = Vector2(-width/2+left, height/2-bottom)
	corners[3].position = Vector2(-width/2+left, -height/2+top)
	
	while sides.size() < 4:
		sides.append(Vector2.ZERO)
	sides[0].position = (corners[0].position+corners[1].position)/2
	sides[1].position = (corners[1].position+corners[2].position)/2
	sides[2].position = (corners[2].position+corners[3].position)/2
	sides[3].position = (corners[3].position+corners[0].position)/2

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var handle = _find_drag_handle_in_range(event.position)
				if handle > -1:
					dragging = true
					curr_handle = drag_handles[handle]
					get_viewport().set_input_as_handled()
					print("now dragging handle ", handle)
			else:
				if dragging:
					dragging = false
					curr_handle = null
					print("released")
					
	if event is InputEventMouseMotion and dragging:
		if curr_handle:
			var world_pos = get_viewport().get_camera_2d().get_canvas_transform().affine_inverse() * event.position
			if curr_handle.adjust_top:
				var new_top = round(world_pos.y + curr_image.get_height()/2)
				top_adjusted.emit(new_top)
			if curr_handle.adjust_right:
				var new_right = round(-world_pos.x + curr_image.get_width()/2)
				right_adjusted.emit(new_right)
			if curr_handle.adjust_bottom:
				var new_bottom = round(-world_pos.y + curr_image.get_height()/2)
				bottom_adjusted.emit(new_bottom)
			if curr_handle.adjust_left:
				var new_left = round(world_pos.x + curr_image.get_width()/2)
				left_adjusted.emit(new_left)
			adjustment_complete.emit()
			get_viewport().set_input_as_handled()


func _find_drag_handle_in_range(screen_pos: Vector2) -> int:
	var world_to_screen_transform = get_viewport().get_camera_2d().get_canvas_transform()
	for i in drag_handles.size():
		var drag_handle_screen_pos = world_to_screen_transform * drag_handles[i].position
		var diff = drag_handle_screen_pos - screen_pos
		if abs(diff.x) <= drag_handle_range and abs(diff.y) <= drag_handle_range:
			return i
	return -1
