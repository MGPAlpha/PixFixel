### Base class for editor tools

class_name ToolBase extends RefCounted

class ChangeDiff:
	var name: String
	
	func apply(img: Image):
		push_error("ChangeDiff is an abstract class, use one of its implementations instead")
	
	func revert(img: Image):
		push_error("ChangeDiff is an abstract class, use one of its implementations instead")

class NewImageChangeDiff extends ChangeDiff:
	var _old_image: Image = Image.new()
	var _new_image: Image = Image.new()
	
	func _init(name: String, old: Image, new: Image) -> void:
		_old_image.copy_from(old)
		_new_image.copy_from(new)
		self.name = name
	
	func apply(img: Image):
		img.copy_from(_new_image)
		
	func revert(img: Image):
		img.copy_from(_old_image)
