class_name TabDisplay extends Control

static var _singleton: TabDisplay
static func get_singleton() -> TabDisplay:
	return _singleton
	
func _init() -> void:
	_singleton = self


class EditorTab extends RefCounted:
	var name:String
	var control:Node
	
var tabs:Array[EditorTab]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TabBar.tab_changed.connect(select_tab)
	$TabBar.tab_close_pressed.connect(close_tab)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_tab(window: Node, name: String):
	var new_tab = EditorTab.new()
	new_tab.name = name
	new_tab.control = window
	
	$TabBar.add_tab(name)
	$TabDisplayWindow.add_child(window)
	var newTabIndex = $TabBar.tab_count - 1
	$TabBar.current_tab = newTabIndex
	$TabBar.ensure_tab_visible(newTabIndex)
	select_tab(newTabIndex)

func select_tab(i: int) -> void:
	for child in $TabDisplayWindow.get_children():
		child.visible = false
	$TabDisplayWindow.get_child(i).visible = true
	print("Selected tab", i)

func close_tab(i: int) -> void:
	$TabBar.remove_tab(i)
	$TabDisplayWindow.remove_child($TabDisplayWindow.get_child(i))
	print("close tab", i)
