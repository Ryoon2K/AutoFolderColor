@tool
class_name AFCConfig extends Resource

##
## This is a config file for setting which file names are colored in what way.
## The key for the dictionary is the name will be used for searching,[br]
## the value is the color that the file or folder will be color as.

##
## This Array will be used to search for Folders that are named the same the key [br]
## and will be colored accodring to the value of the key.
@export var Exact:Array[AFCSelectionData] = []
@export var ExactCS:bool = false

##
## This Array will be used to search for Folders that contain the key [br]
## and will be colored accodring to the value of the key.
@export var Contains:Array[AFCSelectionData] = []
@export var ContainsCS:bool = false

@export var AutoEnabled:bool = false
