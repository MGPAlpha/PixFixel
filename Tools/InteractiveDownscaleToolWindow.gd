class_name InteractiveDownscaleToolWindow extends ToolWindowBase

@export var pixel_display_gizmo: PackedScene
@export var interactive_downscale_gizmo_prefab: PackedScene

@onready var defined_pixels_list = $ScrollContainer/DefinedPixelsList

var current_document: PFDocument

var known_pixels: Array[InteractiveDownscalePixel]
var known_pixel_displays: Array[InteractiveDownscalePixelDisplay]

var interactive_downscale_gizmo: InteractiveDownscaleGizmo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func reset_tool() -> void:
	print("resetting crop tool")
	var current_tab = TabDisplay.get_singleton().current_tab
	if !current_tab || !(current_tab.control is EditorWindow):
		print("No editable tab selected")
		current_document = null
	else:
		current_document = (current_tab.control as EditorWindow).document
		
		
	for display: InteractiveDownscalePixelDisplay in known_pixel_displays:
		display.queue_free()
	known_pixels.clear()
	known_pixel_displays.clear()
	
	if current_document && !interactive_downscale_gizmo:
		interactive_downscale_gizmo = interactive_downscale_gizmo_prefab.instantiate()
		current_document.editor.viewport.add_child(interactive_downscale_gizmo)
		interactive_downscale_gizmo.update_pixels(known_pixels)
		interactive_downscale_gizmo.curr_image = current_document.image
		interactive_downscale_gizmo.add_known_pixel.connect(_add_known_pixel_at_pos)
		interactive_downscale_gizmo.pixel_dragged.connect(_known_pixel_updated)
		print("no gizmo existed")
	elif current_document && interactive_downscale_gizmo:
		interactive_downscale_gizmo.reparent(current_document.editor.viewport)
		interactive_downscale_gizmo.update_pixels(known_pixels)
		interactive_downscale_gizmo.curr_image = current_document.image
		print("gizmo existed, reparented")
	elif interactive_downscale_gizmo:
		interactive_downscale_gizmo.queue_free()
		interactive_downscale_gizmo = null
		print("no point in gizmo, removed")

func _add_known_pixel_at_pos(pos: Vector2) -> void:
	var new_pixel = InteractiveDownscalePixel.new()
	new_pixel.position = pos
	var new_pixel_display = pixel_display_gizmo.instantiate()
	new_pixel_display.index = known_pixels.size()
	known_pixels.append(new_pixel)
	known_pixel_displays.append(new_pixel_display)
	defined_pixels_list.add_child(new_pixel_display)
	new_pixel_display.update_values(new_pixel)
	new_pixel_display.values_changed.connect(_known_pixel_updated)

func _known_pixel_updated(index: int, values: InteractiveDownscalePixel)-> void:
	known_pixels[index] = values
	known_pixel_displays[index].update_values(values)
