class_name TabDisplay extends Control

@onready var tab_bar = $TabBar

static var _singleton: TabDisplay
static func get_singleton() -> TabDisplay:
	return _singleton
	
func _init() -> void:
	_singleton = self
	
var current_tab: EditorTab

signal editor_tab_switched(tab: EditorTab)

class EditorTab extends RefCounted:
	var name:String
	var control:Node
	
var tabs:Array[EditorTab]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TabBar.tab_changed.connect(select_tab)
	$TabBar.tab_close_pressed.connect(close_tab)
	for i in $TabBar.tab_count:
		var new_tab = EditorTab.new()
		new_tab.name = $TabBar.get_tab_title(i)
		new_tab.control = $TabDisplayWindow.get_child(i)
		tabs.append(new_tab)
	if tabs.size() > 0:
		current_tab = tabs[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_tab(window: Control, name: String) -> int:
	var new_tab = EditorTab.new()
	new_tab.name = name
	new_tab.control = window
	window.visible = false
	tabs.append(new_tab)
	$TabBar.add_tab(name)
	$TabDisplayWindow.add_child(window)
	var newTabIndex = $TabBar.tab_count - 1
	return newTabIndex

func select_tab(i: int) -> void:
	#if current_tab == tabs[i]:
		#return
	if current_tab && current_tab.control:
		current_tab.control.visible = false
	if i < 0:
		current_tab = null
		return
	current_tab = tabs[i]
	if current_tab && current_tab.control:
		current_tab.control.visible = true
	ToolOptionsDisplay.get_singleton().reset_current_tool()
	editor_tab_switched.emit(current_tab)
	print("resetting current tool")
	print("Selected tab", i)

func close_tab(i: int) -> void:
	var tab_to_close = tabs[i]
	print("Current tab:", current_tab)
	print("Tab to close:", tab_to_close)
	if current_tab == tab_to_close:
		current_tab = null
	if tab_to_close.control is EditorWindow:
		PFApplication.get_singleton().close_doc((tab_to_close.control as EditorWindow).document)
	tab_to_close.control.queue_free()
	tabs.remove_at(i)
	
	$TabBar.remove_tab(i) # Order important! remove_tab() triggers a new select_tab()
	print("close tab", i)
