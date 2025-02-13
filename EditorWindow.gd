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
	var zoom = scene_camera.zoom.y
	zoom = zoom * amount
	scene_camera.zoom = Vector2(zoom, zoom)
	# TODO handle zoom repositioning
	# TODO bug: zoom occurs in all tabs, not just open one

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			incremental_zoom_toward(1.03, event.position)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			incremental_zoom_toward(0.97, event.position)
