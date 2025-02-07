extends MenuBar


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
			print("pressed Save As")
		2: #Save
			print("pressed Save")

func on_open():
	var file_picker = $OpenDialog
	file_picker.visible = true

func open_file(path: String):
	PFApplication.get_singleton().open_file(path)
