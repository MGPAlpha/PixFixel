class_name CropToolGizmo extends Node2D

var corners: Array[Vector2]
var sides: Array[Vector2]

func _draw() -> void:
	draw_line(corners[0], corners[1], Color.ORANGE)
	draw_line(corners[1], corners[2], Color.ORANGE)
	draw_line(corners[2], corners[3], Color.ORANGE)
	draw_line(corners[3], corners[0], Color.ORANGE)
	
func update_positions(top: int, left: int, right: int, bottom: int, img: Image):
	var width = float(img.get_width())
	var height = float(img.get_height())
	while corners.size() < 4:
		corners.append(Vector2.ZERO)
	corners[0] = Vector2(width/2-right, -height/2+top)
	corners[1] = Vector2(width/2-right, height/2-bottom)
	corners[2] = Vector2(-width/2+left, height/2-bottom)
	corners[3] = Vector2(-width/2+left, -height/2+top)
