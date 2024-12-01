@tool
class_name AFCInputPopup extends Window

signal selected(bool)

@export var FOLDER:= ""
@export var DefaultName:= ""
@export_multiline var boolean_text:= ""
@export var show_warning:bool = true

@onready var bool_popup:AFCBoolPopup = %BoolPopup
@onready var edit:LineEdit = %Edit
@onready var label:Label = %Label

func _ready() -> void:
	connect("visibility_changed",_on_visibility_changed)
	%Save.connect("pressed",_on_save_pressed)
	%Cancel.connect("pressed",_on_cancel_pressed)
	edit.connect("text_changed",_on_text_changed)
	edit.connect("text_submitted",_on_save_pressed)
	
	bool_popup.label.text = boolean_text

func _on_visibility_changed() -> void:
	if visible:
		_set_text()
		position = DisplayServer.mouse_get_position()

func _on_text_changed(new_text:String) -> void:
	var regex := RegEx.create_from_string("([a-zA-Z0-9_-])")
	var matches := regex.search_all(new_text)
	var correct_text:=""
	var pos = edit.caret_column + matches.size() - new_text.length()
	
	for reg in matches:
		if !reg.strings.is_empty():
			correct_text += reg.get_string()
	edit.text = correct_text
	
	edit.caret_column = pos

func _set_text() -> void:
	var files := DirAccess.get_files_at(FOLDER)
	var arr:Array[RegExMatch]
	var regex = RegEx.create_from_string("(%s_)(\\d)+"%DefaultName)
	
	for file in files:
		var matches:Array[RegExMatch] = regex.search_all(file)
		for reg in matches:
			if !reg.strings.is_empty():
				arr.append(reg)
				break
	
	edit.text = "%s_%s"%[DefaultName,str(arr.size()+1)]

# TODO: FIX THE SAME FILE CHECKING
func _on_save_pressed() -> void:
	var file_name:String
	
	file_name = edit.text
	
	var files := DirAccess.get_files_at(FOLDER)
	if files.has("%s.tres"%file_name) and show_warning:
		
		bool_popup.visible = true
		
		var save = await bool_popup.selected
		if !save:return
	
	selected.emit(true)

func _on_cancel_pressed() -> void:
	visible = false
	selected.emit(false)

func _on_close_requested() -> void:
	visible = false


func _on_bool_popup_focus_exited() -> void:
	if visible and !bool_popup.visible: visible = false
