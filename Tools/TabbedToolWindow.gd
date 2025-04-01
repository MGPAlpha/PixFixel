class_name TabbedToolWindow extends ToolWindowBase

@onready var tab_display = $"Tab Display"

func reset_tool():
	var curr_tab = tab_display.get_current_tab_control()
	if curr_tab is ToolWindowBase:
		(curr_tab as ToolWindowBase).reset_tool()
	
func on_tool_hide():
	var curr_tab = tab_display.get_current_tab_control()
	if curr_tab is ToolWindowBase:
		(curr_tab as ToolWindowBase).on_tool_hide()

func _on_tab_switched(index: int):
	print("Tab Switched")
	for tab in tab_display.get_children():
		if tab is ToolWindowBase:
			(tab as ToolWindowBase).on_tool_hide()
	var curr_tab = tab_display.get_current_tab_control()
	if curr_tab is ToolWindowBase:
		(curr_tab as ToolWindowBase).reset_tool()
