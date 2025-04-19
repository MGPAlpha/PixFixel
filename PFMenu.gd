extends MenuBar

@onready var open_dialog = $OpenDialog
@onready var save_as_dialog = $SaveAsDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	$File.id_pressed.connect(on_file_menu_select)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_file_menu_select(id: int):
	match(id):
		0: #Open
			on_open()
		1: #Save As
			on_save_as()
		2: #Save
			print("pressed Save")

func on_open():
	open_dialog.visible = true

func open_file(path: String):
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
	
