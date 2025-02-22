class_name PFDocument
extends RefCounted

var name: String
var path: String

var image: Image

func _init(_path: String) -> void:
	path = _path
	name = _path.get_file()
	image = Image.new()
	image.load(_path)
