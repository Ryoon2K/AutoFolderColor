@tool
class_name AFCSettingsItem extends VBoxContainer

@onready var label: Label = %Label
@onready var check_box: CheckButton = %CheckBox


var property_name:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_text()
	if AFCDock.settings.get(property_name): check_box.set_pressed_no_signal(true)
	else: check_box.set_pressed_no_signal(false)
	
	check_box.connect("toggled",_change_setting)

func _init_text()->void:
	var _text := property_name
	var first := _text.left(1)
	
	_text=_text.right(-1)
	_text=_text.replace("_"," ")
	_text="%s%s"%[first.to_upper(),_text]
	
	label.text = _text

func update() -> void:
	if AFCDock.settings.get(property_name): check_box.set_pressed_no_signal(true)
	else: check_box.set_pressed_no_signal(false)

func _change_setting(on:bool) -> void:
	AFCDock.settings.set(property_name,on)
	AFCDock.instance.save_settings()
