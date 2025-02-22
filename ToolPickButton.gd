extends Button

@export var tool_window_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tool_display = ToolOptionsDisplay.get_singleton()
	var window = tool_window_scene.instantiate()
	tool_display.add_tool(text, window)
	pressed.connect(tool_display.select_tool.bind(text))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
