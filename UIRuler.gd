extends Control

@export var vertical: bool

@export var min_tick_spacing: int = 4
@export var spacing_factor = 10

var viewport: Viewport
var camera: Camera2D
var document: PFDocument

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	viewport = get_viewport()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	draw_set_transform_matrix(get_transform().inverse())
	var bounds = get_rect()
	var bounds_min = bounds.position
	var bounds_max = bounds.position + bounds.size
	
	var world_to_draw_transform = camera.get_canvas_transform()
	var draw_to_world_transform = world_to_draw_transform.affine_inverse()
	
	var doc_size = Vector2(document.image.get_size())
	var doc_bounds = Rect2(-doc_size/2, doc_size)
	var doc_canvas_bounds = world_to_draw_transform * doc_bounds
	var doc_canvas_min = doc_canvas_bounds.position
	var doc_canvas_max = doc_canvas_bounds.position + doc_canvas_bounds.size
	
	if vertical:
		bounds_min.y = max(doc_canvas_min.y, bounds_min.y)
		bounds_max.y = min(doc_canvas_max.y, bounds_max.y)
	else:
		bounds_min.x = max(doc_canvas_min.x, bounds_min.x)
		bounds_max.x = min(doc_canvas_max.x, bounds_max.x)
	
	bounds = Rect2(bounds_min, bounds_max - bounds_min)
	
	draw_rect(bounds, Color.GRAY)
	
	var min_tick_spacing_world = draw_to_world_transform.basis_xform(Vector2(min_tick_spacing, 0)).length()
	var tick_spacing = int(pow(spacing_factor, max(0, ceil(log(min_tick_spacing_world)/log(spacing_factor)))))
	
	var min_doc_pixel = Vector2i((draw_to_world_transform * bounds_min) + doc_size/2)
	var max_doc_pixel = Vector2i((draw_to_world_transform * bounds_max) + doc_size/2)
	
	var first_tick = ceil((min_doc_pixel.y if vertical else min_doc_pixel.x)/tick_spacing)*tick_spacing
	print("Vertical: " if vertical else "Horizontal: ", first_tick)
	while (first_tick <= (max_doc_pixel.y if vertical else max_doc_pixel.x)):
		if vertical:
			var line_level = (world_to_draw_transform * (Vector2(0, first_tick)-doc_size/2)).y
			var line_from = Vector2(bounds_max.x, line_level)
			var line_to = line_from - Vector2(10,0)
			draw_line(line_from, line_to, Color.BLACK)
			
		first_tick += tick_spacing
	
	
	
	
	
	
	
