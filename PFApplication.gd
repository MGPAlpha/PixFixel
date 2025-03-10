class_name PFApplication
extends Node

static var _singleton: PFApplication
static func get_singleton() -> PFApplication:
	return _singleton

var editor_window_scene = preload("res://UIBlocks/editor_window.tscn")

var documents: Array[PFDocument]

func _init() -> void:
	_singleton = self

func open_file(path: String) -> void:
	var new_doc = PFDocument.new(path)
	var new_doc_window = editor_window_scene.instantiate()
	var editor_window = new_doc_window as EditorWindow
	TabDisplay.get_singleton().add_tab(new_doc_window, new_doc.name)
	editor_window.link_to_document(new_doc)
	new_doc.editor = editor_window
	
func close_doc(doc: PFDocument):
	var index = documents.find(doc)
	documents.remove_at(index)
	
