extends Control

@export var vertical: bool

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
	
	var doc_size = Vector2(document.image.get_size())
	var doc_bounds = Rect2(-doc_size/2, doc_size)
	var doc_canvas_bounds = camera.get_canvas_transform() * doc_bounds
	var doc_min = doc_canvas_bounds.position
	var doc_max = doc_canvas_bounds.position + doc_canvas_bounds.size
	
	if vertical:
		bounds_min.y = max(doc_min.y, bounds_min.y)
		bounds_max.y = min(doc_max.y, bounds_max.y)
	else:
		bounds_min.x = max(doc_min.x, bounds_min.x)
		bounds_max.x = min(doc_max.x, bounds_max.x)
	
	bounds = Rect2(bounds_min, bounds_max - bounds_min)
	
	draw_rect(bounds, Color.GRAY)
	
	
	
	
	
