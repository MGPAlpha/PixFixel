class_name PixelGrid extends Node2D

var viewport: Viewport
var camera: Camera2D
var document: PFDocument

@export var show_grid: bool = true
@export var spacing_factor: int = 8
@export var min_line_spacing_screen: int = 25
@export var allow_single_pixel: bool = false
@export var origin_mode: OriginMode = OriginMode.Center
@export var origin: Vector2 = Vector2.ZERO

var overriden: bool = false
var spacing_scale_override: Vector2
var origin_override: Vector2

@export var axis_color: Color = Color.YELLOW
@export var primary_grid_color: Color = Color.ORANGE
@export var secondary_grid_color: Color = Color.TAN

enum OriginMode {
	Center,
	Top,
	TopRight,
	Right,
	BottomRight,
	Bottom,
	BottomLeft,
	Left,
	TopLeft
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport = get_viewport()
	camera = viewport.get_camera_2d()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if show_grid or overriden:
		visible = true
		queue_redraw()
	else:
		visible = false

func recalculate_origin():
	var img_size = document.image.get_size()
	match origin_mode:
		OriginMode.TopLeft, OriginMode.Left, OriginMode.BottomLeft:
			origin.x = -img_size.x/2
		OriginMode.TopRight, OriginMode.Right, OriginMode.BottomRight:
			origin.x = img_size.x/2
		OriginMode.Top, OriginMode.Center, OriginMode.Bottom:
			origin.x = 0 if img_size.x % 2 == 0 else -.5
	
	match origin_mode:
		OriginMode.TopLeft, OriginMode.Top, OriginMode.TopRight:
			origin.y = -img_size.y/2
		OriginMode.BottomLeft, OriginMode.Bottom, OriginMode.BottomRight:
			origin.y = img_size.y/2
		OriginMode.Left, OriginMode.Center, OriginMode.Right:
			origin.y = 0 if img_size.y % 2 == 0 else -.5
	
func reset_origin_mode(mode: OriginMode):
	origin_mode = mode
	recalculate_origin()

func override_grid(new_spacing_scale: Vector2, new_origin: Vector2):
	overriden = true
	spacing_scale_override = new_spacing_scale
	origin_override = new_origin
	
func reset_override():
	overriden = false

func _draw() -> void:
	if !document: return
	
	var transform = camera.get_canvas_transform().affine_inverse()
	var view_size = get_viewport_rect().size
	var document_size = Vector2(document.image.get_size())
	
	var min_world_pos = transform * Vector2.ZERO
	var max_world_pos = transform * view_size
	
	min_world_pos = min_world_pos.clamp(-document_size/2, document_size/2)
	max_world_pos = max_world_pos.clamp(-document_size/2, document_size/2)
	
	var effective_origin = origin
	var spacing_scale = Vector2(1, 1)
	if overriden:
		effective_origin = origin_override
		spacing_scale = Vector2.ONE * spacing_scale_override
	
	var min_line_spacing_world = transform.basis_xform(Vector2(min_line_spacing_screen, 0)).length()
	var spacing_world_x = pow(spacing_factor, ceil(log(min_line_spacing_world/spacing_scale.x)/log(spacing_factor)))*spacing_scale.x
	var spacing_world_y = pow(spacing_factor, ceil(log(min_line_spacing_world/spacing_scale.y)/log(spacing_factor)))*spacing_scale.y
	var spacing_world = Vector2(spacing_world_x, spacing_world_y)
	if overriden:
		if spacing_world.x <= spacing_scale_override.x:
			spacing_world.x = spacing_scale_override.x
		if spacing_world.y <= spacing_scale_override.y:
			spacing_world.y = spacing_scale_override.y
	else:
		if spacing_world.x <= 1 and !allow_single_pixel:
			spacing_world.x = spacing_factor
		if spacing_world.y <= 1 and !allow_single_pixel:
			spacing_world.y = spacing_factor
		
	#Vertical Lines
	var starting_x = ceil((min_world_pos.x - effective_origin.x)/spacing_world.x)*spacing_world.x+effective_origin.x
	var line_index_x = ceili((min_world_pos.x - effective_origin.x)/spacing_world.x)
	while starting_x <= max_world_pos.x:
		draw_line(Vector2(starting_x, -document_size.y/2), Vector2(starting_x, document_size.y/2), axis_color if line_index_x == 0 else (primary_grid_color if line_index_x % spacing_factor == 0 else secondary_grid_color))
		starting_x += spacing_world.x
		line_index_x += 1
		
	#Vertical Lines
	var starting_y = ceil((min_world_pos.y - effective_origin.y)/spacing_world.y)*spacing_world.y+effective_origin.y
	var line_index_y = ceili((min_world_pos.y - effective_origin.y)/spacing_world.y)
	while starting_y <= max_world_pos.y:
		draw_line(Vector2(-document_size.x/2, starting_y), Vector2(document_size.x/2, starting_y), axis_color if line_index_y == 0 else (primary_grid_color if line_index_y % spacing_factor == 0 else secondary_grid_color))
		starting_y += spacing_world.y
		line_index_y += 1
