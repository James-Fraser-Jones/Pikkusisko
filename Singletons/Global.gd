extends Node

# this is a dictionary containing pretty much anything that needs to be saved
var variables : Dictionary

# here's where the variables that are created on starting new game go
const DEFAULT_VARIABLES : Dictionary = {} 

func new_game():
	variables = DEFAULT_VARIABLES
	save_game()

func save_game():
	var file = open_save_file(File.WRITE)
	file.store_string(to_json(variables))

func load_game():
	var file = open_save_file(File.READ)
	var parse_result = JSON.parse(file.get_as_text())
	if parse_result.error != OK:
		push_error("Couldn't load save file. Creating new save file.")
		new_game()
	else:
		variables = parse_result.result
		
func open_save_file(mode : int) -> File:
	var file = File.new()
	file.open("user://save.json",mode)
	return file
