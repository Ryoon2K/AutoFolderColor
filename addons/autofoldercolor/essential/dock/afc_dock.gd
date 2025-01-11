@tool
class_name AFCDock extends Control

signal update_settings_window

var file_format_regx := RegEx.create_from_string(r"(\.[a-zA-Z0-1]+)$")

static var instance:AFCDock
static var config:AFCConfig
static var settings:AFCSettings
static var file_system_dock:FileSystemDock

var afc_folder:String
var selection_scene := preload("components/scenes/afc_selection.tscn")

var exact:= {}
var contains:= {}

var exact_arr:= []
var contains_arr:= []

func _ready() -> void:
	instance = self
	
	file_system_dock = EditorInterface.get_file_system_dock()
	
	#region Button Connection
	%EKButton.connect("pressed",_on_ek_button_pressed)
	%CKButton.connect("pressed",_on_ck_button_pressed)
	%EK_Clear.connect("pressed",_on_ek_clear_button_pressed)
	%CK_Clear.connect("pressed",_on_ck_clear_button_pressed)
	%EKCaps.connect("toggled",_on_ek_caps_toggled)
	%CKCaps.connect("toggled",_on_ck_caps_toggled)
	
	%Apply.connect("pressed",_on_apply_pressed)
	%Auto.connect("toggled",_on_auto_toggled)
	
	%ColorsMenu.get_popup().connect("id_pressed",_on_colors_menu_button_pressed)
	%ConfigMenu.get_popup().connect("id_pressed",_on_config_menu_button_pressed)
	
	%SettingsButton.pressed.connect(func()->void:%SettingsWindow.visible = true)
	#endregion
	
	afc_folder=selection_scene.resource_path.trim_suffix("components/scenes/afc_selection.tscn")
	
	_config_load()
	config = _read_only_fix(config)
	_init_config()
	_init_settings()
	%SettingsWindow.init_items()

## Loads the main configuration resource
func _config_load()->void:
	if !FileAccess.file_exists("%s%s"%["res://addons/autofoldercolor/save_data/","afc_config.tres"]):
		config = AFCConfig.new()
		save_config()
	else:
		config = ResourceLoader.load("%s%s"%["res://addons/autofoldercolor/save_data/","afc_config.tres"],"",ResourceLoader.CACHE_MODE_IGNORE)
## This is used to fix an AFC config if it loads with Read_Only arrays.
## It happens if a array is saved empty. Makes the Array functionally useless.
func _read_only_fix(afc_config:AFCConfig)->AFCConfig:
# Checks if either array is read only.
	if afc_config.Contains.is_read_only() or afc_config.Exact.is_read_only():
	# Duplicates the afc config
		var dupe := afc_config.duplicate(true)
		afc_config = AFCConfig.new()
	# If the arrays aren't empty it repopulates the duplicate
		if !dupe.Contains.is_empty():
			for item in dupe.Contains:
				afc_config.Contains.append(item)
		if !dupe.Exact.is_empty():
			for item in dupe.Exact:
				afc_config.Exact.append(item)
				
	return afc_config
## Initializes the config by populating the dock with the loaded information.
func _init_config()->void:
	for item in config.Exact:
		var selection_node:AFCSelectionItem = selection_scene.instantiate()
		selection_node.data = item
		selection_node.dict = exact
		selection_node.arr_check = exact_arr
		
		selection_node.item_deleted.connect(_on_item_updated)
		selection_node.item_updated.connect(_on_item_updated)
		
		%EK_VBox.add_child(selection_node)
	%EKCaps.set_pressed_no_signal(config.ExactCS)
	
	for item in config.Contains:
		var selection_node:AFCSelectionItem = selection_scene.instantiate()
		selection_node.data = item
		selection_node.dict = contains
		selection_node.arr_check = contains_arr
		
		selection_node.item_deleted.connect(_on_item_updated)
		selection_node.item_updated.connect(_on_item_updated)
		
		%CK_VBox.add_child(selection_node)
	%CKCaps.set_pressed_no_signal(config.ContainsCS)
	
	var dd_array:Array
	recur_get_dir_dialog(file_system_dock,dd_array)
	
	if config.AutoEnabled: dd_array[1].connect("visibility_changed",_on_dir_cr_dialog_visiblity_changed)
	%Auto.set_pressed_no_signal(config.AutoEnabled)
	
## Saves the current config to the afc_folder path
func save_config()->void:
	var err:int = DirAccess.make_dir_absolute("res://addons/autofoldercolor/save_data")
	match err:
		0:
			pass
		32:
			pass
		_:
			print("Unexpected error when saving: "+error_string(err))
	ResourceSaver.save(config,"%s%s"%["res://addons/autofoldercolor/save_data/","afc_config.tres"])
## Used to clear both lists when loading a configuration
func _clear_keywords() -> void:
	for item:AFCSelectionItem in %EK_VBox.get_children():
		item.delete()
	for item:AFCSelectionItem in %CK_VBox.get_children():
		item.delete()
	
	contains.clear()
	exact.clear()

## Initializes settings
func _init_settings()->void:
	_load_settings()
	apply_settings()
## Loads settings
func _load_settings()->void:
	if !FileAccess.file_exists("%s%s"%["res://addons/autofoldercolor/save_data/","afc_settings.tres"]):
		settings = AFCSettings.new()
		save_settings()
	else:
		settings = ResourceLoader.load("%s%s"%["res://addons/autofoldercolor/save_data/","afc_settings.tres"],"",ResourceLoader.CACHE_MODE_IGNORE)
## Saves settings
func save_settings()->void:
	var err:int = DirAccess.make_dir_absolute("res://addons/autofoldercolor/save_data")
	match err:
		0:
			pass
		32:
			pass
		_:
			print("Unexpected error when saving: "+error_string(err))
	ResourceSaver.save(settings,"%s%s"%["res://addons/autofoldercolor/save_data/","afc_settings.tres"])
	apply_settings()
## Applies the updated settings
func apply_settings()->void:
	update_settings_window.emit()
	
	var _props:= settings.get_property_list()
	for prop:Dictionary in _props:
		match prop.name:
			"show_apply_info_panel":
				%InfoPopup.settings_property = prop.name
			"show_apply_warning":
				%ApplyPopup.settings_property = prop.name
			"show_load_warning":
				%LoadMenu.show_warning = settings.get(prop.name)
				%LoadMenu.bool_popup.settings_property = prop.name
			"show_save_overwrite_warning":
				%SaveMenu.show_warning = settings.get(prop.name)
				%SaveMenu.bool_popup.settings_property = prop.name
			"show_backup_overwrite_warning":
				%BackupMenu.show_warning = settings.get(prop.name)
				%BackupMenu.bool_popup.settings_property = prop.name
			"show_restore_colors_warning":
				%RestoreMenu.show_warning = settings.get(prop.name)
				%RestoreMenu.bool_popup.settings_property = prop.name
			"show_clear_colors_warning":
				%ClearColorsPopup.settings_property = prop.name
			"show_turn_on_auto_warning":
				%AutoPopup.settings_property = prop.name

#region Button Function
## Adds a keyword item to the 'Exact' or 'Contains' list
func _on_ek_button_pressed()->void:
	var selection_node:AFCSelectionItem = selection_scene.instantiate()
	var afc_data = AFCSelectionData.new()
	
	config.Exact.append(afc_data)
	selection_node.data = afc_data
	selection_node.dict = exact
	selection_node.arr_check = exact_arr
	
	selection_node.item_deleted.connect(_on_item_updated)
	selection_node.item_updated.connect(_on_item_updated)
	
	%EK_VBox.add_child(selection_node)
	save_config()
func _on_ck_button_pressed()->void:
	var selection_node:AFCSelectionItem = selection_scene.instantiate()
	var afc_data = AFCSelectionData.new()
	
	config.Contains.append(afc_data)
	selection_node.data = afc_data
	selection_node.dict = contains
	selection_node.arr_check = contains_arr
	
	selection_node.item_deleted.connect(_on_item_updated)
	selection_node.item_updated.connect(_on_item_updated)
	
	%CK_VBox.add_child(selection_node)
	save_config()

## Clears all items from the 'Exact' or 'Contains' list
func _on_ek_clear_button_pressed():
	if settings.show_clear_exact_list_warning:
		%ClearExactPopup.label.text = "Are you sure you want to clear every keyword in this list?"
		%ClearExactPopup.visible = true
		var answer:bool = await %ClearExactPopup.selected
		if !answer:return
	
	for item:AFCSelectionItem in %EK_VBox.get_children():
		item.delete()
		exact.clear()
	save_config()
func _on_ck_clear_button_pressed():
	if settings.show_clear_contains_list_warning:
		%ClearContainsPopup.label.text = "Are you sure you want to clear every keyword in this list?"
		%ClearContainsPopup.visible = true
		var answer:bool = await %ClearContainsPopup.selected
		if !answer:return
	
	for item:AFCSelectionItem in %CK_VBox.get_children():
		item.delete()
		contains.clear()
	save_config()

## Applies the colors from the two lists
func _on_apply_pressed() -> void:
	if settings.show_apply_warning:
		%ApplyPopup.label.text = "This will change the colors of your files.\nThis won't affect any other file that is not listed."
		%ApplyPopup.visible = true
		var answer:bool = await %ApplyPopup.selected
		
		if !answer:return
	
	_change_colors()
	

## This is the main function for changing colors using the keywords
func _change_colors()->void:
	var _dict:={}
	var file_colors:={}
	if ProjectSettings.get_setting("file_customization/folder_colors"):
		file_colors = ProjectSettings.get_setting("file_customization/folder_colors")
	
	_set_colors_recursive("res://",_dict)
	
	if settings.clear_everything_before_applying:
		file_colors = {}
		ProjectSettings.set_setting("file_customization/folder_colors",file_colors)
	
	file_colors.merge(_dict,true)
	
	ProjectSettings.set_setting("file_customization/folder_colors",file_colors)
	ProjectSettings.save()
	
	if settings.show_apply_info_panel:
		%InfoPopup.visible = true

## This method currently does nothing. [br]
## This method will connect/disconnect signals from the FileSystem [br]
## It will call the previous method whenever a folder supposedly gets added
func _on_auto_toggled(on:bool) -> void:
	if settings.show_turn_on_auto_warning:
		if on:
			%AutoPopup.label.text = "The addon will now detect when a file has been created and change all folder colors."
		else:
			%AutoPopup.label.text = "You will now have to manually click to apply the configuration."
		%AutoPopup.visible = true
		var answer:bool = await %ApplyPopup.selected
			
		if !answer:return
	
	var dd_array:Array
	recur_get_dir_dialog(file_system_dock,dd_array)
	
	if on and !dd_array[1].is_connected("visibility_changed",_on_dir_cr_dialog_visiblity_changed):
		dd_array[1].connect("visibility_changed",_on_dir_cr_dialog_visiblity_changed)
	elif !on and dd_array[1].is_connected("visibility_changed",_on_dir_cr_dialog_visiblity_changed):
		dd_array[1].disconnect("visibility_changed",_on_dir_cr_dialog_visiblity_changed)
	
	config.AutoEnabled = on
	save_config()

## Makes sure the Dialog went invisible before calling the change colors function
func _on_dir_cr_dialog_visiblity_changed()->void:
	var dd_array:Array
	recur_get_dir_dialog(file_system_dock,dd_array)
	if !dd_array[1].visible:
		await get_tree().process_frame
		_change_colors()

## Gets all of the Directory Create Dialog objects and puts them in the array
func recur_get_dir_dialog(object:Variant,array:Array)->void:
	if object.get_class() == "DirectoryCreateDialog": array.append(object)
	
	else:
		for child in object.get_children():recur_get_dir_dialog(child,array)

## Detect which Configuration Menu button was pressed
func _on_config_menu_button_pressed(id:int)->void:
	match id:
		0: _on_load_pressed()
		1: _on_save_pressed()

## Loads / Saves the currently set lists as a configuration
func _on_load_pressed() -> void:
	%LoadMenu.visible = true
	
	var is_selected:bool = await %LoadMenu.selected
	if !is_selected:return
	
	var id = %LoadMenu.OB.get_selected_id()
	var idx = %LoadMenu.OB.get_item_index(id)
	
	var folder:String =  %LoadMenu.FOLDER
	var file_name:String = %LoadMenu.OB.get_item_text(idx)
	var new_config:AFCConfig = ResourceLoader.load("%s%s.tres"%[folder,file_name],"",ResourceLoader.CACHE_MODE_IGNORE)
	
	_clear_keywords()
	
	config = new_config
	config = _read_only_fix(config)
	_init_config()
	
	_items_duplicates_check()
	save_config()
	%LoadMenu.visible = false
func _on_save_pressed() -> void:
	var err:int = DirAccess.make_dir_absolute("res://addons/autofoldercolor/save_data/saved_configs")
	match err:
		0:
			pass
		32:
			pass
		_:
			print("Unexpected error when saving: "+error_string(err))
	
	%SaveMenu.visible = true
	var is_selected:bool = await %SaveMenu.selected
	if !is_selected:return
	
	var folder:String =  %SaveMenu.FOLDER
	var file_name:String = %SaveMenu.edit.text
	
	ResourceSaver.save(config,"res://addons/autofoldercolor/save_data/saved_configs/%s.tres"%[file_name])
	
	%SaveMenu.visible = false

## Detect which Colors Menu button was pressed
func _on_colors_menu_button_pressed(id:int)->void:
	match id:
		0: _on_backup_pressed()
		1: _on_restore_pressed()
		2: _on_clear_pressed()

## Backs up / Restores the currently set FileSystem colors

func _on_backup_pressed() -> void:
	var err:int = DirAccess.make_dir_absolute("res://addons/autofoldercolor/save_data/backups")
	match err:
		0:
			pass
		32:
			pass
		_:
			print("Unexpected error when saving: "+error_string(err))
	
	%BackupMenu.visible = true
	var is_selected:bool = await %BackupMenu.selected
	if !is_selected:return
	
	var folder:String =  %BackupMenu.FOLDER
	var file_name:String = %BackupMenu.edit.text
	var backup_res := AFCBackup.new()
	
	backup_res.folder_colors = ProjectSettings.get_setting("file_customization/folder_colors")
	ResourceSaver.save(backup_res,"res://addons/autofoldercolor/save_data/backups/%s.tres"%[file_name])
	
	%BackupMenu.visible = false
func _on_restore_pressed() -> void:
	%RestoreMenu.visible = true
	var is_selected:bool = await %RestoreMenu.selected
	if !is_selected: return
	
	var id = %RestoreMenu.OB.get_selected_id()
	var idx = %RestoreMenu.OB.get_item_index(id)
	
	var folder:String =  %RestoreMenu.FOLDER
	var file_name:String = %RestoreMenu.OB.get_item_text(idx)
	var backup_res:AFCBackup = ResourceLoader.load("%s%s.tres"%[folder,file_name])
	
	ProjectSettings.set("file_customization/folder_colors",backup_res.folder_colors)
	ProjectSettings.save()
	
	%RestoreMenu.visible = false

## Clears all currently set file colors
func _on_clear_pressed() -> void:
	if settings.show_clear_colors_warning:
		%ClearColorsPopup.label.text = "This will fully clear all current colors of your files.\nAre you sure?"
		%ClearColorsPopup.visible = true
		
		var selection:bool = await %ClearColorsPopup.selected
		
		if !selection:return
	
	ProjectSettings.set_setting("file_customization/folder_colors",{})
	ProjectSettings.save()

func _on_ck_caps_toggled(on:bool)->void:
	config.ContainsCS = on
	save_config()

func _on_ek_caps_toggled(on:bool)->void:
	config.ExactCS = on
	save_config()

#endregion

## Whenever a list item gets update it checks for duplicates
func _on_item_updated() -> void:
	_items_duplicates_check()
	save_config()
func _items_duplicates_check() -> void:
	for item:AFCSelectionItem in %CK_VBox.get_children():
		if item.is_blocked:item.has_duplicate()
	for item:AFCSelectionItem in %EK_VBox.get_children():
		if item.is_blocked:item.has_duplicate()
	pass

## Recursively goes through every folder and checks if it fits the criteria.
## Anything that fits the given criteria will be added to a dictionary.
func _set_colors_recursive(path:String,_dict:Dictionary):
	var files:= DirAccess.get_files_at(path)
	if files.has(".gdignore"):return[]
	var folders:= DirAccess.get_directories_at(path)
	
	for item in folders:
		for c in contains.keys():
		## Checks if the Caps Sensitive is on
			if config.ContainsCS:
				if item.find(c) != -1:_dict["%s%s/"%[path,item]] = contains[c]
			else:
				if item.to_lower().find(c.to_lower()) != -1:_dict["%s%s/"%[path,item]] = contains[c]
	
	for item in folders:
		for e in exact.keys():
			## Checks if the Caps Sensitive is on
			if config.ExactCS:
				if item == e: _dict["%s%s/"%[path,item]] = exact[e]
			else:
				if item.to_lower() == e.to_lower(): _dict["%s%s/"%[path,item]] = exact[e]
	
	for folder in folders:
		_set_colors_recursive("%s%s/"%[path,folder],_dict)
