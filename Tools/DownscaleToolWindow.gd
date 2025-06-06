class_name DownscaleToolWindow extends ToolWindowBase

@onready var simple_width_box = $"Downscale Modes/Simple/Resolution Controls/Width Container/WidthBox"
@onready var simple_height_box = $"Downscale Modes/Simple/Resolution Controls/Height Container/HeightBox"
@onready var simple_confirm_button = $"Downscale Modes/Simple/Confirm Button"

var current_document: PFDocument

var simple_height: int
var simple_width: int

var smart_height: int
var smart_width: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func reset_tool():
	var current_tab = TabDisplay.get_singleton().current_tab
	if !current_tab || !(current_tab.control is EditorWindow):
		print("No editable tab selected")
		current_document = null
	else:
		current_document = (current_tab.control as EditorWindow).document
	
	simple_width = 0
	simple_height = 0
	
	if current_document:
		simple_width = current_document.image.get_width()
		simple_height = current_document.image.get_height()
	
	_update_simple_tab()
	
func _update_simple_tab():
	var img_width = 0
	var img_height = 0
	if current_document:
		img_width = current_document.image.get_width()
		img_height = current_document.image.get_height()
	
	simple_width_box.set_value_no_signal(0)
	simple_height_box.set_value_no_signal(0)
	
	simple_width_box.min_value = 0
	simple_height_box.min_value = 0

	simple_width_box.max_value = img_width
	simple_height_box.max_value = img_height
	
	simple_width_box.set_value_no_signal(simple_width)
	simple_height_box.set_value_no_signal(simple_height)
	
func _confirm_simple_downscale():
	var downscale = DownscaleTool.new()
	
	simple_width = simple_width_box.value
	simple_height = simple_height_box.value
	
	var diff = await downscale.downscale_simple(current_document.image, simple_width, simple_height)
	current_document.apply_new_change(diff)
	
	reset_tool()
	
func _confirm_smart_analyze():
	var img = current_document.image
	var fourier = FourierTools.get_2d_fft(img)
	
	var fourier_display = TextureRect.new()
	fourier_display.name = "Fourier"
	fourier_display.texture = ImageTexture.create_from_image(fourier[0])
	TabDisplay.get_singleton().add_tab(fourier_display, "Fourier")
	
	var phase_display = TextureRect.new()
	phase_display.name = "Fourier"
	phase_display.texture = ImageTexture.create_from_image(fourier[1])
	TabDisplay.get_singleton().add_tab(phase_display, "Phase")
