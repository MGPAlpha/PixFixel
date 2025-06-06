class_name CropTool extends ToolBase

func applyCrop(img: Image, top: int, left: int, right: int, bottom: int) -> NewImageChangeDiff:
	var original_width = img.get_width()
	var original_height = img.get_height()
	
	var new_width = original_width - left - right
	var new_height = original_height - top - bottom
	
	var new_img = Image.create_empty(new_width, new_height, false, img.get_format())
	
	new_img.blit_rect(img, Rect2i(left, top, new_width, new_height), Vector2.ZERO)
	
	return NewImageChangeDiff.new("Crop", img, new_img)
