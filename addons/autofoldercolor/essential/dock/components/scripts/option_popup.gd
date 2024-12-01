@tool
class_name AFCOptionPopup extends Window

signal selected(bool)


@onready var OB:OptionButton = %OptionButton
@onready var label := %Label

@export var FOLDER:String = ""
@export var bool_popup:AFCBoolPopup
@export_multiline var boolean_text:String
@export var show_warning:bool = true

func _ready() -> void:
	connect("visibility_changed",_on_visibility_changed)
	OB.connect("pressed",_change_size)
	OB.connect("item_selected",_on_item_selected)
	bool_popup.label.text = boolean_text

func _on_visibility_changed() -> void:
	if visible:
		_get_options()
		position = DisplayServer.mouse_get_position()
	else:
		selected.emit(false)
		_clear_options()

func _clear_options() -> void:
	OB.clear()
	OB.set_pressed(false)

func _get_options() -> void:
	var files := DirAccess.get_files_at(FOLDER)
	for file in files:
		OB.add_item(file.trim_suffix(".tres"))

func _change_size() -> void:
	if OB.button_pressed: size.y = 60+min((38*OB.item_count),400)
	else: size.y = 60

func _on_item_selected(idx) -> void:
	if idx == -1:return
	size.y = 60
	
	if show_warning:
		bool_popup.visible = true
		var is_selected:bool = await bool_popup.selected
		if !is_selected:return
	
	selected.emit(true)

func _on_close_requested() -> void:
	visible = false

func _on_focus_exited() -> void:
	if visible and !bool_popup.visible: visible = false
