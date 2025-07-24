class_name SimpleDownscaleToolWindow extends ToolWindowBase

@onready var width_box = $"Resolution Controls/Width Container/WidthBox"
@onready var height_box = $"Resolution Controls/Height Container/HeightBox"
@onready var aspect_toggle = $"Resolution Controls/Aspect Ratio Container/AspectRatioToggle"
@onready var confirm_button = $"Confirm Button"

var height: int
var width: int

var aspect_lock = true
var aspect: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset_tool():
	super.reset_tool()
	
	print("Resetting Simple Downscale Tool")
	
	width = 1
	height = 1
	aspect_lock = true
	
	if current_document:
		width = current_document.image.get_width()
		height = current_document.image.get_height()
	
	aspect = float(width)/height
		
	width_box.set_value_no_signal(1)
	height_box.set_value_no_signal(1)
	
	width_box.min_value = 1
	height_box.min_value = 1

	width_box.max_value = width
	height_box.max_value = height
	
	width_box.set_value_no_signal(width)
	height_box.set_value_no_signal(height)
	
	aspect_toggle.button_pressed = true
	
	if current_document:
		confirm_button.disabled = false
	else:
		confirm_button.disabled = true
	
	_update_simple_tab()
	
func _update_from_width_edit():
	width = width_box.value
	if (aspect_lock):
		height = width / aspect
	_update_simple_tab()
	
func _update_from_height_edit():
	height = height_box.value
	if (aspect_lock):
		width = height * aspect
	_update_simple_tab()
	
func _aspect_lock_toggled():
	aspect_lock = aspect_toggle.button_pressed
	if aspect_lock:
		aspect = float(width)/height

func _update_simple_tab():
	
	width_box.set_value_no_signal(width)
	height_box.set_value_no_signal(height)
	
	if current_document:
		confirm_button.disabled = false
	else:
		confirm_button.disabled = true
	
func _confirm_downscale():
	var downscale = DownscaleTool.new()
	
	width = width_box.value
	height = height_box.value
	
	var diff = await downscale.downscale_simple(current_document.image, width, height)
	current_document.apply_new_change(diff)
	
	current_editor.zoom_to_fit()
	
	reset_tool()
