class_name CropToolWindow extends ToolWindowBase

@onready var width_box = $"Size Controls/WidthContainer/WidthBox"
@onready var height_box = $"Size Controls/HeightContainer/HeightBox"
@onready var top_box = $"Margin Controls/TopContainer/TopBox"
@onready var left_box = $"Margin Controls/LeftContainer/LeftBox"
@onready var right_box = $"Margin Controls/RightContainer/RightBox"
@onready var bottom_box = $"Margin Controls/BottomContainer/BottomBox"

var crop_top: int = 0
var crop_left: int = 0
var crop_right: int = 0
var crop_bottom: int = 0

var current_document: PFDocument = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func reset_tool():
	var current_tab = TabDisplay.get_singleton().current_tab
	if !current_tab || !(is_instance_of(current_tab.control, EditorWindow)):
		print("No editable tab selected")
		current_document = null
	else:
		current_document = (current_tab.control as EditorWindow).document
	crop_top = 0
	crop_left = 0
	crop_right = 0
	crop_bottom = 0
	_update_entry_display()
	
func _update_from_size_edit():
	var img_width = 0
	var img_height = 0
	if current_document:
		img_width = current_document.image.get_width()
		img_height = current_document.image.get_height()
	crop_right = img_width - crop_left - width_box.value
	crop_bottom = img_height - crop_top - height_box.value
	_update_entry_display()

func _update_from_margin_edit():
	crop_top = top_box.value
	crop_left = left_box.value
	crop_right = right_box.value
	crop_bottom = bottom_box.value
	_update_entry_display()
		
func _update_entry_display():
	var img_width = 0
	var img_height = 0
	if (current_document):
		img_width = current_document.image.get_width()
		img_height = current_document.image.get_height()

	top_box.max_value = img_height - crop_bottom
	bottom_box.max_value = img_height - crop_top
	left_box.max_value = img_width - crop_right
	right_box.max_value = img_width - crop_left
	
	top_box.min_value = 0
	bottom_box.min_value = 0
	left_box.min_value = 0
	right_box.min_value = 0
	
	width_box.max_value = img_width - crop_left
	width_box.min_value = 0
	height_box.max_value = img_height - crop_top
	height_box.min_value = 0
	
	top_box.set_value_no_signal(crop_top)
	left_box.set_value_no_signal(crop_left)
	right_box.set_value_no_signal(crop_right)
	bottom_box.set_value_no_signal(crop_bottom)
	
	width_box.set_value_no_signal(img_width - crop_left - crop_right)
	height_box.set_value_no_signal(img_height - crop_top - crop_bottom)
