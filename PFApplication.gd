class_name PFApplication
extends Node

static var _singleton: PFApplication
static func get_singleton() -> PFApplication:
	return _singleton

var documents: Array[PFDocument]

func _init() -> void:
	_singleton = self

func open_file(path: String) -> void:
	pass
