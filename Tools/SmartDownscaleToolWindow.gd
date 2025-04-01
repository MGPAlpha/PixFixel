class_name SmartDownscaleToolWindow extends ToolWindowBase

var current_document: PFDocument

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

func _confirm_smart_analyze():
	var doc = current_document
	var img = doc.image
	var fourier = FourierTools.get_2d_fft(img)
	
	var fourier_display = TextureRect.new()
	fourier_display.name = "Fourier"
	fourier_display.texture = ImageTexture.create_from_image(fourier[0])
	TabDisplay.get_singleton().add_tab(fourier_display, "Frequency Space of " + doc.name)
	
	var phase_display = TextureRect.new()
	phase_display.name = "Fourier"
	phase_display.texture = ImageTexture.create_from_image(fourier[1])
	TabDisplay.get_singleton().add_tab(phase_display, "Phase Space of " + doc.name)
