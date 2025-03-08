@tool
class_name AFC extends EditorPlugin

static var colors:Array[String] = [
	"red",
	"orange",
	"yellow",
	"green",
	"teal",
	"blue",
	"purple",
	"pink",
	"gray",
	"black",
	]

static var afc_dock

static var char_regex = RegEx.create_from_string(r"[\\\/:*?\"<>|]")

func _enter_tree() -> void:
	afc_dock = preload("essential/dock/afc_dock.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR,afc_dock)

func _exit_tree() -> void:
	remove_control_from_docks(afc_dock)
	afc_dock.free()
