extends Node

const SAVEGAME = "user://mijocraftSave.json"

var save_data = {}

func _ready():
	save_data = get_data()
	
func get_data():
	var file = File.new()
	if not file.file_exists(SAVEGAME):
		save_data = {"nickname" : Server.nickname, "color" : Server.playerColor}
		save_game()
	file.open(SAVEGAME, File.READ)
	var content = file.get_as_text()
	var data = parse_json(content)
	save_data = data
	file.close()
	return(data)
		
func save_game():
	var save_game = File.new()
	save_game.open(SAVEGAME, File.WRITE)
	save_game.store_line(to_json(save_data))
