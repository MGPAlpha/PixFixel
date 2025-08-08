class_name CropToolWindow extends ToolWindowBase

@onready var width_box = $"Size Controls/WidthContainer/WidthBox"
@onready var height_box = $"Size Controls/HeightContainer/HeightBox"
@onready var aspect_toggle = $"Size Controls/Aspect Ratio Container/AspectRatioToggle"
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

var adj_top: int = -1
var adj_right: int = -1
var adj_bottom: int = -1
var adj_left: int = -1

var aspect_lock: bool
var aspect: float

var crop_gizmo: CropToolGizmo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func reset_tool():
	super.reset_tool()
	
	print("resetting crop tool")
	
	crop_top = 0
	crop_left = 0
	crop_right = 0
	crop_bottom = 0

	aspect = 1
	aspect_lock = false

	_update_aspect()
	
	print("current doc: ", current_document)
	print("crop gizmo: ", crop_gizmo)
	
	if current_document && !crop_gizmo:
		crop_gizmo = crop_gizmo_prefab.instantiate()
		current_editor.viewport.add_child(crop_gizmo)
		crop_gizmo.update_positions(crop_top, crop_left, crop_right, crop_bottom, current_document.image)
		crop_gizmo.top_adjusted.connect(_adjust_top)
		crop_gizmo.right_adjusted.connect(_adjust_right)
		crop_gizmo.bottom_adjusted.connect(_adjust_bottom)
		crop_gizmo.left_adjusted.connect(_adjust_left)
		crop_gizmo.center_adjusted.connect(_adjust_center)
		crop_gizmo.adjustment_complete.connect(_adjustment_complete)
		crop_gizmo.gizmo_released.connect(_update_aspect)
		print("no gizmo existed")
	elif current_document && crop_gizmo:
		crop_gizmo.reparent(current_editor.viewport)
		crop_gizmo.update_positions(crop_top, crop_left, crop_right, crop_bottom, current_document.image)
		print("gizmo existed, reparented")
	elif crop_gizmo:
		crop_gizmo.queue_free()
		crop_gizmo = null
		print("no point in gizmo, removed")
	_update_entry_display()
	
func on_tool_hide():
	if crop_gizmo:
		crop_gizmo.queue_free()
		crop_gizmo = null

func _update_aspect():
	var img_width = 1
	var img_height = 1
	if current_document:
		img_width = current_document.image.get_width()
		img_height = current_document.image.get_height()
	var width = img_width - crop_left - crop_right
	var height = img_height - crop_top - crop_bottom
	aspect = float(width)/height

func _aspect_lock_toggled():
	aspect_lock = aspect_toggle.button_pressed
	if aspect_lock:
		_update_aspect()

func _update_from_width_edit():
	if aspect_lock:
		var img_width = current_document.image.get_width()
		var img_height = current_document.image.get_height()
		
		var new_width = width_box.value
		var new_height = int(new_width / aspect)
		
		if new_height > img_height - crop_top:
			new_height = img_height - crop_top
		_update_from_size_edit(new_width, new_height)
	else:
		_update_from_size_edit(width_box.value, height_box.value)
	
func _update_from_height_edit():
	if aspect_lock:
		var img_width = current_document.image.get_width()
		var img_height = current_document.image.get_height()
		
		var new_height = height_box.value
		var new_width = int(new_height * aspect)
		
		if new_width > img_width - crop_left:
			new_width = img_width - crop_left
		_update_from_size_edit(new_width, new_height)
	else:
		_update_from_size_edit(width_box.value, height_box.value)

func _update_from_size_edit(width: int, height: int):
	var img_width = 0
	var img_height = 0
	if current_document:
		img_width = current_document.image.get_width()
		img_height = current_document.image.get_height()
	crop_right = img_width - crop_left - width
	crop_bottom = img_height - crop_top - height
	if !aspect_lock:
		_update_aspect()
	_update_entry_display()

func _update_from_margin_edit():
	crop_top = top_box.value
	crop_left = left_box.value
	crop_right = right_box.value
	crop_bottom = bottom_box.value
	_update_aspect()
	_update_entry_display()
	
func _adjust_top(val: int):
	val = clamp(val, 0, current_document.image.get_height() - crop_bottom)
	adj_top = val
	
func _adjust_right(val: int):
	val = clamp(val, 0, current_document.image.get_width() - crop_left)
	adj_right = val
	
func _adjust_bottom(val: int):
	val = clamp(val, 0, current_document.image.get_height() - crop_top)
	adj_bottom = val
	
func _adjust_left(val: int):
	val = clamp(val, 0, current_document.image.get_width() - crop_right)
	adj_left = val
	
func _adjustment_complete(as_lock: bool):
	if (as_lock):
		if ((adj_top > -1) != (adj_bottom > -1)) and ((adj_left > -1) != (adj_right > -1)): # condition for a vertical and horizontal movement
			var img_width = current_document.image.get_width()
			var img_height = current_document.image.get_height()
			var potential_width = img_width - (adj_left if adj_left > -1 else crop_left) - (adj_right if adj_right > -1 else crop_right)
			var potential_height = img_height - (adj_top if adj_top > -1 else crop_top) - (adj_bottom if adj_bottom > -1 else crop_bottom)
			
			var potential_aspect = float(potential_width)/potential_height
			
			if potential_aspect > aspect: #height too small
				potential_height = int(potential_width / aspect)
			elif potential_aspect < aspect: #width too small
				potential_width = int(potential_height * aspect)
				
			if (adj_top > -1):
				adj_top = img_height - crop_bottom - potential_height
				adj_top = max(adj_top, 0)
			if (adj_bottom > -1):
				adj_bottom = img_height - crop_top - potential_height
				adj_bottom = max(adj_bottom, 0)
			if (adj_right > -1):
				adj_right = img_width - crop_left - potential_width
				adj_right = max(adj_right, 0)
			if (adj_left > -1):
				adj_left = img_width - crop_right - potential_width
				adj_left = max(adj_left, 0)
				
			_apply_adjustments()
			
			print("doing aspect lock")
				
		else:
			_apply_adjustments()
	else:
		_apply_adjustments()
	_update_entry_display()
	
func _apply_adjustments():
	if (adj_top > -1):
		crop_top = adj_top
	if (adj_right > -1):
		crop_right = adj_right
	if (adj_bottom > -1):
		crop_bottom = adj_bottom
	if (adj_left > -1):
		crop_left = adj_left
		
	adj_top = -1
	adj_right = -1
	adj_bottom = -1
	adj_left = -1

func _adjust_center(val: Vector2):
	var doc_size = current_document.image.get_size()
	var curr_size = doc_size - Vector2i(crop_left + crop_right, crop_top + crop_bottom)
	var half_size = curr_size/2.0
	val = val.clamp(half_size, Vector2(doc_size) - half_size)
	if curr_size.x % 2 == 0:
		val.x = round(val.x)
	else:
		val.x = round(val.x+.5)-.5
	if curr_size.y % 2 == 0:
		val.y = round(val.y)
	else:
		val.y = round(val.y+.5)-.5
	crop_top = val.y - half_size.y
	crop_right = doc_size.x - val.x - half_size.x
	crop_bottom = doc_size.y - val.y - half_size.y
	crop_left = val.x - half_size.x

func _gizmo_drag_started():
	_update_aspect()
	adj_top = -1
	adj_right = -1
	adj_bottom = -1
	adj_left = -1

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
	width_box.set_value_no_signal(0)
	height_box.set_value_no_signal(0)

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
	
	var diff = await crop.applyCrop(current_document.image, crop_top, crop_left, crop_right, crop_bottom)
	current_document.apply_new_change(diff)
	
	reset_tool()
