extends MenuBar

@onready var open_dialog = $OpenDialog
@onready var save_as_dialog = $SaveAsDialog

var last_open_path: String

var file: PopupMenu
var edit: PopupMenu

var view: PopupMenu
var zoom: PopupMenu
var grid_size: PopupMenu
var grid_origin: PopupMenu

enum FileMenu {
	Open,
	SaveAs
}

enum EditMenu {
	Undo,
	Redo
}

enum ViewMenu {
	ZoomSubmenu,
	GridSeparator,
	ShowGrid,
	GridSizeSubmenu,
	GridOriginSubmenu
}

enum ZoomMenu {
	ZoomIn,
	ZoomOut,
	ZoomToFit,
	Zoom100
}

enum GridSizeMenu {
	Grid4,
	Grid8,
	Grid10,
	Grid16
}

func _build_file_menu():
	file = PopupMenu.new()
	file.name = "File"
	
	file.add_item("Open", FileMenu.Open, KEY_MASK_CTRL | KEY_O)
	file.add_item("Save As", FileMenu.SaveAs, KEY_MASK_CTRL | KEY_S)
	
	file.id_pressed.connect(_on_file_menu_select)
	
	return file

func _build_edit_menu():
	edit = PopupMenu.new()
	edit.name = "Edit"
	
	edit.add_item("Undo", EditMenu.Undo, KEY_MASK_CTRL | KEY_Z)
	edit.add_item("Redo", EditMenu.Redo, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_Z)
	
	edit.id_pressed.connect(_on_edit_menu_select)
	
	return edit

func _build_view_menu():
	view = PopupMenu.new()
	view.name = "View"
	
	var zoom_menu = _build_zoom_menu()
	view.add_submenu_node_item("Zoom", zoom_menu, ViewMenu.ZoomSubmenu)
	
	view.add_separator("Grid", ViewMenu.GridSeparator)
	view.add_check_item("Show Grid", ViewMenu.ShowGrid)
	
	var grid_size_menu = _build_grid_size_menu()
	view.add_submenu_node_item("Grid Size", grid_size_menu, ViewMenu.GridSizeSubmenu)
	
	var grid_origin_menu = _build_grid_origin_menu()
	view.add_submenu_node_item("Grid Origin", grid_origin_menu, ViewMenu.GridOriginSubmenu)
	
	view.id_pressed.connect(_on_view_menu_select)
	
	return view

func _build_zoom_menu():
	zoom = PopupMenu.new()
	
	zoom.add_item("Zoom In", ZoomMenu.ZoomIn, KEY_MASK_CTRL | KEY_PLUS)
	zoom.add_item("Zoom Out", ZoomMenu.ZoomOut, KEY_MASK_CTRL | KEY_MINUS)
	zoom.add_item("Zoom To Fit", ZoomMenu.ZoomToFit)
	zoom.add_item("Zoom 100%", ZoomMenu.Zoom100)
	
	zoom.id_pressed.connect(_on_zoom_menu_select)
	
	return zoom
	
func _build_grid_size_menu():
	grid_size = PopupMenu.new()
	
	grid_size.add_radio_check_item("4x4", GridSizeMenu.Grid4)
	grid_size.add_radio_check_item("8x8", GridSizeMenu.Grid8)
	grid_size.add_radio_check_item("10x10", GridSizeMenu.Grid10)
	grid_size.add_radio_check_item("16x16", GridSizeMenu.Grid16)
	
	grid_size.id_pressed.connect(_on_grid_size_menu_select)
	
	return grid_size

func _build_grid_origin_menu():
	grid_origin = PopupMenu.new()
	
	grid_origin.add_radio_check_item("Center", PixelGrid.OriginMode.Center)
	grid_origin.add_radio_check_item("Top", PixelGrid.OriginMode.Top)
	grid_origin.add_radio_check_item("Top Right", PixelGrid.OriginMode.TopRight)
	grid_origin.add_radio_check_item("Right", PixelGrid.OriginMode.Right)
	grid_origin.add_radio_check_item("Bottom Right", PixelGrid.OriginMode.BottomRight)
	grid_origin.add_radio_check_item("Bottom", PixelGrid.OriginMode.Bottom)
	grid_origin.add_radio_check_item("Bottom Left", PixelGrid.OriginMode.BottomLeft)
	grid_origin.add_radio_check_item("Left", PixelGrid.OriginMode.Left)
	grid_origin.add_radio_check_item("Top Left", PixelGrid.OriginMode.TopLeft)
	
	grid_origin.id_pressed.connect(_on_grid_origin_menu_select)
	
	return grid_origin

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://file_config.cfg")
	
	if err == OK:
		last_open_path = config.get_value("file_config", "last_open_path")
		open_dialog.current_path = last_open_path
	
	var file_menu = _build_file_menu()
	add_child(file_menu)
	var edit_menu = _build_edit_menu()
	add_child(edit_menu)
	var view_menu = _build_view_menu()
	add_child(view_menu)
	


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
		file.set_item_disabled(FileMenu.SaveAs, false)
		
		var can_undo = editor.document.undo_stack.size() > 0
		var can_redo = editor.document.redo_stack.size() > 0
		
		edit.set_item_disabled(EditMenu.Undo, !can_undo)
		var undo_text = "Undo"
		if can_undo:
			undo_text += " " + editor.document.undo_stack[-1].name
		edit.set_item_text(EditMenu.Undo, undo_text)
		
		edit.set_item_disabled(EditMenu.Redo, !can_redo)
		var redo_text = "Redo"
		if can_redo:
			redo_text += " " + editor.document.redo_stack[-1].name
		edit.set_item_text(EditMenu.Redo, redo_text)
		
		view.set_item_disabled(ViewMenu.ZoomSubmenu, false)
		
		view.set_item_disabled(ViewMenu.ShowGrid, false)
		view.set_item_checked(ViewMenu.ShowGrid, editor.pixel_grid.show_grid)
		
		view.set_item_disabled(ViewMenu.GridSizeSubmenu, false)
		var grid_size = editor.pixel_grid.spacing_factor
		_update_grid_size_menu(grid_size)
		view.set_item_disabled(ViewMenu.GridOriginSubmenu, false)
		_update_grid_origin_menu(editor.pixel_grid.origin_mode)
		
	else:
		file.set_item_disabled(FileMenu.SaveAs, true)
		
		edit.set_item_disabled(EditMenu.Undo, true)
		edit.set_item_disabled(EditMenu.Redo, true)
		
		view.set_item_disabled(ViewMenu.ShowGrid, true)
		view.set_item_disabled(ViewMenu.GridSizeSubmenu, true)
		view.set_item_disabled(ViewMenu.GridOriginSubmenu, true)
		view.set_item_disabled(ViewMenu.ZoomSubmenu, true)
		
func _update_grid_size_menu(curr_size: int):
	grid_size.set_item_checked(GridSizeMenu.Grid4, curr_size == 4)
	grid_size.set_item_checked(GridSizeMenu.Grid8, curr_size == 8)
	grid_size.set_item_checked(GridSizeMenu.Grid10, curr_size == 10)
	grid_size.set_item_checked(GridSizeMenu.Grid16, curr_size == 16)
	
func _update_grid_origin_menu(curr_mode: PixelGrid.OriginMode):
	for index in PixelGrid.OriginMode:
		grid_origin.set_item_checked(PixelGrid.OriginMode[index], false)
	grid_origin.set_item_checked(curr_mode, true)

func _on_file_menu_select(id: int):
	match(id):
		FileMenu.Open:
			on_open()
		FileMenu.SaveAs:
			_on_save_as()

func _on_edit_menu_select(id: int):
	match(id):
		EditMenu.Undo:
			_on_undo()
		EditMenu.Redo:
			_on_redo()

func _on_view_menu_select(id: int):
	var current_tab = TabDisplay.get_singleton().current_tab
	var editor = current_tab.control as EditorWindow
	match id:
		ViewMenu.ShowGrid:
			if !editor: return
			editor.pixel_grid.show_grid = !editor.pixel_grid.show_grid
			view.set_item_checked(ViewMenu.ShowGrid, editor.pixel_grid.show_grid)

func _on_zoom_menu_select(id: int):
	var current_tab = TabDisplay.get_singleton().current_tab
	var editor = current_tab.control as EditorWindow
	if !editor: return
	match(id):
		ZoomMenu.ZoomIn:
			if editor:
				editor.incremental_zoom(1.2)
		ZoomMenu.ZoomOut:
			if editor:
				editor.incremental_zoom(.8)
		ZoomMenu.ZoomToFit:
			if editor:
				editor.zoom_to_fit()
		ZoomMenu.Zoom100:
			if editor:
				editor.zoom_absolute(1)
			
func _on_grid_size_menu_select(id: int):
	var current_tab = TabDisplay.get_singleton().current_tab
	var editor = current_tab.control as EditorWindow
	if !editor: return
	match(id):
		GridSizeMenu.Grid4:
			editor.pixel_grid.spacing_factor = 4
		GridSizeMenu.Grid8:
			editor.pixel_grid.spacing_factor = 8
		GridSizeMenu.Grid10:
			editor.pixel_grid.spacing_factor = 10
		GridSizeMenu.Grid16:
			editor.pixel_grid.spacing_factor = 16
	_update_grid_size_menu(editor.pixel_grid.spacing_factor)
	
func _on_grid_origin_menu_select(id: int):
	var current_tab = TabDisplay.get_singleton().current_tab
	var editor = current_tab.control as EditorWindow
	if !editor: return
	editor.pixel_grid.reset_origin_mode(id)
	_update_grid_origin_menu(id)

func on_open():
	open_dialog.visible = true

func _open_file(path: String):
	last_open_path = path
	PFApplication.get_singleton().open_file(path)

func _on_save_as():
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
	
	if event is InputEventKey && event.pressed:
		event = event as InputEventKey
		var keycode_with_modifiers = event.get_keycode_with_modifiers()
		if keycode_with_modifiers == KEY_MASK_CTRL | KEY_EQUAL || keycode_with_modifiers == KEY_MASK_CTRL | KEY_KP_ADD:
			_on_zoom_menu_select(ZoomMenu.ZoomIn)
			accept_event()
		elif keycode_with_modifiers == KEY_MASK_CTRL | KEY_KP_SUBTRACT:
			_on_zoom_menu_select(ZoomMenu.ZoomOut)
			accept_event()
