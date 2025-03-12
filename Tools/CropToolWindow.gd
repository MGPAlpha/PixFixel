class_name CropToolWindow extends ToolWindowBase

@onready var width_box = $"Size Controls/WidthContainer/WidthBox"
@onready var height_box = $"Size Controls/HeightContainer/HeightBox"
@onready var top_box = $"Margin Controls/TopContainer/TopBox"
@onready var left_box = $"Margin Controls/LeftContainer/LeftBox"
@onready var right_box = $"Margin Controls/RightContainer/RightBox"
@onready var bottom_box = $"Margin Controls/BottomContainer/BottomBox"
@onready var confirm_button = $"Confirm Button"

@export var crop_gizmo_prefab: PackedScene

var crop_top: int = 0
var crop_left: int = 0
var crop_right: int = 0
var crop_bottom: int = 0

var current_document: PFDocument = null

var crop_gizmo: CropToolGizmo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func reset_tool():
	print("resetting crop tool")
	var current_tab = TabDisplay.get_singleton().current_tab
	if !current_tab || !(current_tab.control is EditorWindow):
		print("No editable tab selected")
		current_document = null
	else:
		current_document = (current_tab.control as EditorWindow).document
	crop_top = 0
	crop_left = 0
	crop_right = 0
	crop_bottom = 0
	
	print("current tab: ", current_tab)
	if current_tab:
		print("current tab name: ", current_tab.name)
	print("current doc: ", current_document)
	print("crop gizmo: ", crop_gizmo)
	
	if current_document && !crop_gizmo:
		crop_gizmo = crop_gizmo_prefab.instantiate()
		current_document.editor.viewport.add_child(crop_gizmo)
		crop_gizmo.update_positions(crop_top, crop_left, crop_right, crop_bottom, current_document.image)
		crop_gizmo.top_adjusted.connect(_adjust_top)
		crop_gizmo.right_adjusted.connect(_adjust_right)
		crop_gizmo.bottom_adjusted.connect(_adjust_bottom)
		crop_gizmo.left_adjusted.connect(_adjust_left)
		crop_gizmo.adjustment_complete.connect(_update_entry_display)
		print("no gizmo existed")
	elif current_document && crop_gizmo:
		crop_gizmo.reparent(current_document.editor.viewport)
		crop_gizmo.update_positions(crop_top, crop_left, crop_right, crop_bottom, current_document.image)
		print("gizmo existed, reparented")
	elif crop_gizmo:
		crop_gizmo.queue_free()
		crop_gizmo = null
		print("no point in gizmo, removed")
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
	
func _adjust_top(val: int):
	val = clamp(val, 0, current_document.image.get_height() - crop_bottom)
	print("adjusting top")
	crop_top = val
	
func _adjust_right(val: int):
	val = clamp(val, 0, current_document.image.get_width() - crop_left)
	print("adjusting right")
	crop_right = val
	
func _adjust_bottom(val: int):
	val = clamp(val, 0, current_document.image.get_height() - crop_top)
	crop_bottom = val
	
func _adjust_left(val: int):
	val = clamp(val, 0, current_document.image.get_width() - crop_right)
	crop_left = val
		
func _update_entry_display():
	var img_width = 0
	var img_height = 0
	if (current_document):
		img_width = current_document.image.get_width()
		img_height = current_document.image.get_height()

	top_box.set_value_no_signal(0)
	left_box.set_value_no_signal(0)
	right_box.set_value_no_signal(0)
	bottom_box.set_value_no_signal(0)

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
	
	if current_document == null || crop_top == 0 && crop_left == 0 && crop_right == 0 && crop_bottom == 0:
		confirm_button.disabled = true
	else:
		confirm_button.disabled = false
		
	if crop_gizmo:
		crop_gizmo.update_positions(crop_top, crop_left, crop_right, crop_bottom, current_document.image)
		crop_gizmo.queue_redraw()
	
func _confirm_crop():
	var crop = CropTool.new()
	
	var diff = crop.applyCrop(current_document.image, crop_top, crop_left, crop_right, crop_bottom)
	diff.apply(current_document.image)
	current_document.editor.texture.set_image(current_document.image)
	
	reset_tool()
