extends Node2D

const player = preload("res://scenes/player.tscn")
const block = preload("res://blockClasses/block.tscn")

var loadedWorld = {}
onready var players = $players

func _ready():
	load_world_data()

func load_world_data():
	var file = File.new()
	file.open("res://worlds/defaultWorld.json", File.READ)
	var content = file.get_as_text()
	var data = parse_json(content)
	loadedWorld = data
	file.close()
	
	for i in loadedWorld["blocks"]:
		place_block(i["id"], i["xpos"], i["ypos"], false)
	
	for i in loadedWorld["walls"]:
		place_block(i["id"], i["xpos"], i["ypos"], true)
	
remote func receive_placed_block(id : int, xpos: int, ypos: int, isWall : bool):
	var placedBlock = block.instance()
	placedBlock.ID = id
	placedBlock.position = Vector2(xpos, ypos)
	if !isWall:
		$blockMode.add_child(placedBlock)
		rpc("place_block", id, placedBlock.position.x, placedBlock.position.y, false)
	else:
		$wallMode.add_child(placedBlock)
		rpc("place_block", id, placedBlock.position.x, placedBlock.position.y, true)
		
remote func receive_broke_block(blockPosition : Vector2, isWall : bool):
	if !isWall:
		for i in $blockMode.get_children():
			if get_node(i.get_path()).position == blockPosition:
				get_node(i.get_path()).queue_free()
				rpc("break_block", blockPosition, false)
	else:
		for i in $wallMode.get_children():
			if get_node(i.get_path()).position == blockPosition:
				get_node(i.get_path()).queue_free()
				rpc("break_block", blockPosition, true)
	
remote func scan_blocks():
	var newData = {"blocks" : [], "walls" : []}
	for i in $blockMode.get_children():
		newData["blocks"].append({"id":get_node(i.get_path()).ID, "xpos":get_node(i.get_path()).position.x, "ypos":get_node(i.get_path()).position.y})
		
	for i in $wallMode.get_children():
		newData["walls"].append({"id":get_node(i.get_path()).ID, "xpos":get_node(i.get_path()).position.x, "ypos":get_node(i.get_path()).position.y})
		
	loadedWorld = newData
	rpc("receive_world_data", loadedWorld)
		
func place_block(id : int, xpos : int, ypos : int, isWall : bool):
	var placedBlock = block.instance()
	placedBlock.ID = id
	placedBlock.position = Vector2(xpos, ypos)
	if !isWall:
		$blockMode.add_child(placedBlock)
	else:
		$wallMode.add_child(placedBlock)

remote func spawn_players(id):
	var plyr = player.instance()
	plyr.name = str(id)
	players.add_child(plyr)
	rpc("spawn_player", id)
	
func remove_player(id):
	$players.get_node(str(id)).queue_free()
	rpc("delete_player", id)
