@tool
class_name AFCSettingsItem extends VBoxContainer

@onready var label: Label = %Label
@onready var check_box: CheckButton = %CheckBox

var property_name:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_color()
	_init_text()
	if AFCDock.settings.get(property_name): check_box.set_pressed_no_signal(true)
	else: check_box.set_pressed_no_signal(false)
	
	check_box.connect("toggled",_change_setting)

# Checks which item it is and sets the color so it alternates light and dark grey
func _init_color()->void:
	if get_parent().get_children().find(self)%2:
		%ColorRect.color = Color("#454545")
	else: %ColorRect.color = Color("#383838")


func _init_text()->void:
	var _text := property_name
	var first := _text.left(1)
	
	_text=_text.right(-1)
	_text=_text.replace("_"," ")
	_text="%s%s"%[first.to_upper(),_text]
	
	label.text = _text

# Checks the settings and updates the button
func update() -> void:
	if AFCDock.settings.get(property_name):
		check_box.set_pressed_no_signal(true)
	else:
		check_box.set_pressed_no_signal(false)

# Changes the setting
func _change_setting(on:bool) -> void:
	AFCDock.settings.set(property_name,on)
	AFCDock.instance.save_settings()
