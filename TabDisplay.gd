class_name TabDisplay extends Control

static var _singleton: TabDisplay
static func get_singleton() -> TabDisplay:
	return _singleton
	
func _init() -> void:
	_singleton = self
	
var current_tab: EditorTab


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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_tab(window: Node, name: String):
	var new_tab = EditorTab.new()
	new_tab.name = name
	new_tab.control = window
	tabs.append(new_tab)
	$TabBar.add_tab(name)
	$TabDisplayWindow.add_child(window)
	var newTabIndex = $TabBar.tab_count - 1
	$TabBar.current_tab = newTabIndex
	$TabBar.ensure_tab_visible(newTabIndex)
	select_tab(newTabIndex)

func select_tab(i: int) -> void:
	if current_tab && current_tab.control:
		current_tab.control.visible = false
	current_tab = tabs[i]
	if current_tab && current_tab.control:
		current_tab.control.visible = true
	print("Selected tab", i)

func close_tab(i: int) -> void:
	$TabBar.remove_tab(i)
	$TabDisplayWindow.remove_child($TabDisplayWindow.get_child(i))
	print("close tab", i)
