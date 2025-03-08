@tool
class_name AFCSettingsPopup extends Window

static var instance:AFCSettingsPopup
var item_scene:=preload("afc_settings_item.tscn")

static var loaded_settings:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	visibility_changed.connect(_on_visibility_changed)
	close_requested.connect(func()->void:visible = false)

# When visibilty changes it moves near the mouse cursor
func _on_visibility_changed() -> void:
	if visible:position = DisplayServer.mouse_get_position()+Vector2i(size.x/5,-(size.y/2))

# Initalizes the settings list 
func init_items() -> void:
	for prop in AFCDock.settings.get_property_list():
		if prop.usage == 4102:
			var item:AFCSettingsItem = item_scene.instantiate()
			item.property_name = prop.name
			loaded_settings[prop.name] = item
			%MainVBox.add_child(item)


func update_all_items() -> void:
	for child:AFCSelectionItem in %MainVBox.get_children():
		child.update()

# Updates the settings item to display the current value
func update_item(_property:String) -> void:
	loaded_settings[_property].update()

# Fixes loaded_settings if, for some reason, it is empty.
func fix_settings() -> void:
	if !%MainVBox.get_children().is_empty():
		for item:AFCSelectionItem in %MainVBox.get_children():
			loaded_settings[item.name] = item
