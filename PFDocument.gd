class_name PFDocument
extends RefCounted

var name: String
var path: String

var image: Image

var undo_stack: Array[ToolBase.ChangeDiff]
var redo_stack: Array[ToolBase.ChangeDiff]

signal edited

func _init(_path: String) -> void:
	path = _path
	name = _path.get_file()
	image = Image.new()
	image.load(_path)
	#var avg_value = 0
	#for i in image.get_width():
		#for j in image.get_height():
			#var color = image.get_pixel(i, j)
			#avg_value += color.r
			#avg_value += color.g
			#avg_value += color.b
	#avg_value /= (image.get_width() * image.get_height() * 3)
	#print("Average value: ", avg_value)

func undo():
	if undo_stack.size() == 0:
		print("Nothing to undo")
		return
	var change = undo_stack.pop_back()
	change.revert(image)
	redo_stack.push_back(change)
	edited.emit()
	
func redo():
	if redo_stack.size() == 0:
		print("Nothing to redo")
		return
	var change = redo_stack.pop_back()
	change.apply(image)
	undo_stack.push_back(change)
	edited.emit()
	
func apply_new_change(change: ToolBase.ChangeDiff):
	redo_stack.clear()
	change.apply(image)
	undo_stack.push_back(change)
	edited.emit()
