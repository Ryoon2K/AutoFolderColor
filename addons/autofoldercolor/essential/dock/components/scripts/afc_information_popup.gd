@tool
extends Window

var settings_property:String


func _ready() -> void:
	%Ok.connect("pressed",_on_ok_pressed)
	connect("visibility_changed",_on_visibility_changed)
	connect("close_requested",_on_ok_pressed)

func _on_visibility_changed() -> void:
	if visible:
		position = DisplayServer.mouse_get_position()
	else:
		if %Disable/Button.button_pressed:
			AFCDock.settings.set(settings_property,false)
			AFCDock.instance.save_settings()
			AFCSettingsPopup.instance.update_item(settings_property)
			%Disable/Button.set_pressed_no_signal(false)

func _on_ok_pressed() -> void:
	visible = false
