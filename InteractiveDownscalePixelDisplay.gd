class_name InteractiveDownscalePixelDisplay extends VBoxContainer

@onready var pixel_x_box = $PixelContainer/PixelXBox
@onready var pixel_y_box = $PixelContainer/PixelYBox

@onready var position_x_box = $PositionContainer/PositionXBox
@onready var position_y_box = $PositionContainer/PositionYBox

var index: int

signal values_changed(index: int, pixel: InteractiveDownscalePixel)
signal delete_pressed(index: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_value_box_changed() -> void:
	print("change registered")
	var pixel = InteractiveDownscalePixel.new()
	pixel.pixel = Vector2i(pixel_x_box.value, pixel_y_box.value)
	pixel.position = Vector2(position_x_box.value, position_y_box.value)
	values_changed.emit(index, pixel)

func update_values(vals: InteractiveDownscalePixel):
	pixel_x_box.set_value_no_signal(vals.pixel.x)
	pixel_y_box.set_value_no_signal(vals.pixel.y)
	position_x_box.set_value_no_signal(vals.position.x)
	position_y_box.set_value_no_signal(vals.position.y)
