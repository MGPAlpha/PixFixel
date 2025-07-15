class_name ToolWindowBase extends VBoxContainer
	
var current_document: PFDocument
var current_editor: EditorWindow
	
func reset_tool():
	var current_tab = TabDisplay.get_singleton().current_tab
	if !current_tab || !(current_tab.control is EditorWindow):
		print("No editable tab selected")
		current_document = null
		current_editor = null
	else:
		
		current_editor = current_tab.control as EditorWindow
		current_document = current_editor.document
	
func on_tool_hide():
	pass
