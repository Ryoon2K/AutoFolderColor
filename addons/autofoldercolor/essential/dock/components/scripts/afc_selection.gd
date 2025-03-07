@tool
class_name AFCSelectionItem extends HBoxContainer

signal item_deleted
signal item_updated

@onready var edit:LineEdit = $LineEdit
@onready var OB:OptionButton = $OptionButton

@export var data:AFCSelectionData

var dict:={}
var is_blocked:bool = false
var old_keyword:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_ob()
	_on_init()
	
	$Button.connect("pressed",delete)
	$LineEdit.connect("text_changed",_on_text_changed)
	$OptionButton.connect("item_selected",_on_item_selected)

func _init_ob() -> void:
	OB.clear()
	var texture:= GradientTexture2D.new()
	
	texture.gradient = Gradient.new()
	texture.gradient.remove_point(1)
	
	texture.width = 10
	texture.height = 10
	
	for idx:int in AFC.colors.size():
		var color:Color
		texture = texture.duplicate()
		texture.gradient = texture.gradient.duplicate()
		
		match AFC.colors[idx]:
			"blue": color = Color.DEEP_SKY_BLUE
			"teal": color = Color.LIGHT_SEA_GREEN
			"gray": color = Color.DIM_GRAY
			"pink": color = Color.DEEP_PINK
			"purple": color = Color.REBECCA_PURPLE
			_: color = Color(AFC.colors[idx])
		
		texture.gradient.set_color(0,Color(color))
		
		OB.add_item(AFC.colors[idx].to_pascal_case(),idx)
		OB.set_item_icon(idx,texture)

func _on_init() -> void:
	edit.add_theme_stylebox_override("normal",edit.get_theme_stylebox("normal").duplicate(true))
	
	if !data:return
	if !data.keyword:
		data.color = OB.get_item_text(OB.selected).to_lower()
		return
	
	if data.color != null : OB.select(AFC.colors.find(data.color))
	else:data.color = OB.get_item_text(OB.selected).to_lower()
	edit.text = data.keyword
	
	has_duplicate()
	
# TODO: ADD REGEX FOR CHARACTERS
func _on_text_changed(new_text:String) -> void:
	var old_keyword:String = data.keyword
	data.keyword = new_text
	dict.erase(old_keyword)
	
	has_duplicate()
	if !is_blocked:
		if data.keyword:dict[data.keyword] = data.color
	item_updated.emit()

func _on_item_selected(idx:int) -> void:
	var color:String = OB.get_item_text(idx).to_lower()
	data.color = color
	if !is_blocked and data.keyword != "": dict[data.keyword] = color
	item_updated.emit()

# TODO: IT DOESN'T DELETE FROM THE CONFIG
#		* WHEN SAVING AND RELOADING IT LOADS THE PREVIOUS CONFIG
#		WITH THE DELETED ITEMS
func delete() -> void:
	if AFCDock.config.Exact.has(data):AFCDock.config.Exact.erase(data)
	if AFCDock.config.Contains.has(data):AFCDock.config.Contains.erase(data)
	if !is_blocked:dict.erase(data.keyword)
	
	item_deleted.emit()
	
	queue_free()

func has_duplicate() -> bool:
	if dict.keys().has(data.keyword):
		_set_blocked(true)
		return true
	
	_set_blocked(false)
	if data.keyword:dict[data.keyword] = data.color
	return false

func _set_blocked(val:bool) -> void:
	is_blocked = val
	
	if val:
		edit.tooltip_text = "There is a duplicate keyword for this list.\n This keyword won't be used to apply colors."
		edit.get_theme_stylebox("normal").bg_color = Color("#4f0b06c1")
	else:
		edit.tooltip_text = ""
		edit.get_theme_stylebox("normal").bg_color = Color("#090912bd")
