@tool
class_name AFCBoolPopup extends Window

signal selected(bool)

@onready var label = %Label
var settings_property:String

func _ready() -> void:
	%Yes.connect("pressed",_emit_true)
	%No.connect("pressed",_emit_false)
	connect("close_requested",_emit_false)
	connect("visibility_changed",_on_visibility_changed)

func _on_visibility_changed() -> void:
	if !visible:
		_emit_false()
		
		# If the disable button is pressed then it changes the setting
		if %Disable/Button.button_pressed:
			AFCDock.settings.set(settings_property,false)
			AFCDock.instance.save_settings()
			AFCSettingsPopup.instance.update_item(settings_property)
			%Disable/Button.set_pressed_no_signal(false)
	else:
		position = DisplayServer.mouse_get_position()

func _emit_true() -> void:
	selected.emit(true)
	visible = false

func _emit_false() -> void:
	selected.emit(false)
	visible = false
