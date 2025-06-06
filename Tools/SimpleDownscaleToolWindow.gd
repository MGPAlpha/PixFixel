class_name SimpleDownscaleToolWindow extends ToolWindowBase

@onready var width_box = $"Resolution Controls/Width Container/WidthBox"
@onready var height_box = $"Resolution Controls/Height Container/HeightBox"
@onready var confirm_button = $"Confirm Button"

var current_document: PFDocument

var height: int
var width: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset_tool():
	print("Resetting Simple Downscale Tool")
	var current_tab = TabDisplay.get_singleton().current_tab
	if !current_tab || !(current_tab.control is EditorWindow):
		print("No editable tab selected")
		current_document = null
	else:
		current_document = (current_tab.control as EditorWindow).document
	
	width = 0
	height = 0
	
	if current_document:
		width = current_document.image.get_width()
		height = current_document.image.get_height()
	
	_update_simple_tab()
	
func _update_simple_tab():
	var img_width = 0
	var img_height = 0
	if current_document:
		img_width = current_document.image.get_width()
		img_height = current_document.image.get_height()
	
	width_box.set_value_no_signal(0)
	height_box.set_value_no_signal(0)
	
	width_box.min_value = 0
	height_box.min_value = 0

	width_box.max_value = img_width
	height_box.max_value = img_height
	
	width_box.set_value_no_signal(width)
	height_box.set_value_no_signal(height)
	
func _confirm_downscale():
	var downscale = DownscaleTool.new()
	
	width = width_box.value
	height = height_box.value
	
	var diff = await downscale.downscale_simple(current_document.image, width, height)
	current_document.apply_new_change(diff)
	
	reset_tool()
