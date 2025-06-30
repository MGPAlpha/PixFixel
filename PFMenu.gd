extends MenuBar

@onready var open_dialog = $OpenDialog
@onready var save_as_dialog = $SaveAsDialog

var last_open_path: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	$File.id_pressed.connect(on_file_menu_select)
	$Edit.id_pressed.connect(on_edit_menu_select)
	
	var config = ConfigFile.new()
	var err = config.load("user://file_config.cfg")
	
	if err == OK:
		last_open_path = config.get_value("file_config", "last_open_path")
		open_dialog.current_path = last_open_path


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _exit_tree() -> void:
	var config = ConfigFile.new()
	config.set_value("file_config", "last_open_path", last_open_path)
	config.save("user://file_config.cfg")
	

func _update_menus():
	var current_tab = TabDisplay.get_singleton().current_tab
	var editor = current_tab.control as EditorWindow
	if editor:
		$File.set_item_disabled(1, false)
		var can_undo = editor.document.undo_stack.size() > 0
		var can_redo = editor.document.redo_stack.size() > 0
		$Edit.set_item_disabled(0, !can_undo)
		$Edit.set_item_disabled(1, !can_redo)
	else:
		$File.set_item_disabled(1, true)
		$Edit.set_item_disabled(0, true)
		$Edit.set_item_disabled(1, true)

func on_file_menu_select(id: int):
	match(id):
		0: #Open
			on_open()
		1: #Save As
			on_save_as()
		2: #Save
			print("pressed Save")

func on_edit_menu_select(id: int):
	match(id):
		0: #Undo
			_on_undo()
		1: #Redo
			_on_redo()

func on_open():
	open_dialog.visible = true

func open_file(path: String):
	last_open_path = path
	PFApplication.get_singleton().open_file(path)

func on_save_as():
	var curr_tab = TabDisplay.get_singleton().current_tab.control
	if !curr_tab or !(curr_tab is EditorWindow):
		print("No file available to save!")
		return
	var curr_doc = (curr_tab as EditorWindow).document
	var original_path = curr_doc.path
	save_as_dialog.current_path = original_path
	save_as_dialog.visible = true
	
func _on_save_as_file_selected(path: String):
	var curr_tab = TabDisplay.get_singleton().current_tab.control
	if !curr_tab or !(curr_tab is EditorWindow):
		print("No file available to save!")
		return
	var curr_doc = (curr_tab as EditorWindow).document
	var curr_image = curr_doc.image
	var file_type = path.get_extension()
	match file_type:
		"png":
			curr_image.save_png(path)
		"jpg", "jpeg":
			curr_image.save_jpg(path)
		"webp":
			curr_image.save_webp(path)
		"exr":
			curr_image.save_exr(path)
	
func _on_undo():
	var curr_tab = TabDisplay.get_singleton().current_tab.control
	if !curr_tab or !(curr_tab is EditorWindow):
		print("No file open to undo!")
		return
	var curr_doc = (curr_tab as EditorWindow).document
	
	curr_doc.undo()
	if (ToolOptionsDisplay.get_singleton()):
		ToolOptionsDisplay.get_singleton().reset_current_tool()

func _on_redo():
	var curr_tab = TabDisplay.get_singleton().current_tab.control
	if !curr_tab or !(curr_tab is EditorWindow):
		print("No file open to redo!")
		return
	var curr_doc = (curr_tab as EditorWindow).document
	
	curr_doc.redo()
	if (ToolOptionsDisplay.get_singleton()):
		ToolOptionsDisplay.get_singleton().reset_current_tool()
		

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_redo"):
		_on_redo()
		accept_event()
	elif event.is_action_pressed("ui_undo"):
		_on_undo()
		accept_event()
