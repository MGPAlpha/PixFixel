class_name PFDocument
extends RefCounted

var name: String
var path: String

var image: Image
var editor: EditorWindow

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
