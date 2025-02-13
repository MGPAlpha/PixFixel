class_name EditorWindow extends SubViewportContainer

var document: PFDocument
var texture: ImageTexture

@onready var canvas_sprite = $SubViewport/Sprite2D
@onready var scene_camera = $SubViewport/Camera2D
@onready var viewport = $SubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func link_to_document(doc: PFDocument) -> void:
	document = doc
	texture = ImageTexture.create_from_image(document.image)
	canvas_sprite.texture = texture
	zoom_to_fit()
	
func zoom_to_fit() -> void:
	var zoom = min(float(viewport.size.y) / float(document.image.get_height()), float(viewport.size.x) / float(document.image.get_width()))
	scene_camera.zoom = Vector2(zoom, zoom)
	
func incremental_zoom_toward(amount: float, toward: Vector2) -> void:
	var cam_zoom = scene_camera.zoom.y
	cam_zoom = cam_zoom * amount
	var mouse_world_pos = scene_camera.get_canvas_transform().affine_inverse() * toward
	var offset_initial = mouse_world_pos - scene_camera.position
	var offset_final = offset_initial * amount
	var offset_diff = offset_final - offset_initial
	scene_camera.position += offset_diff
	scene_camera.zoom = Vector2(cam_zoom, cam_zoom)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			incremental_zoom_toward(1.03, event.position)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			incremental_zoom_toward(0.97, event.position)

#func _input(event):
	
