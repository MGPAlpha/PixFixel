class_name ToolOptionsDisplay extends VBoxContainer

static var _singleton: ToolOptionsDisplay
static func get_singleton() -> ToolOptionsDisplay:
	return _singleton
	
func _init() -> void:
	_singleton = self

@onready var tool_window = $ToolOptionsDisplayWindow

var tool_windows: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_tool(name: String, window: Control):
	print("Adding tool ", name)

func select_tool(name: String):
	print("Selecting tool", name)
