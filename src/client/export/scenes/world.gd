extends Node2D

const plyr = preload("res://scenes/player.tscn")
onready var players = $players
onready var spawnpoint = $spawn

var worldData = {"blocks" : [], "walls" : []}
var loadedWorld = {}

var player

signal finishedScan
signal finishedRWD

var breakingParticles = preload("res://scenes/breakingParticles.tscn")

remote func spawn_player(id):
	player = plyr.instance()
	player.name = str(id)
	players.add_child(player)
	player.set_network_master(id)
	player.position = spawnpoint.position

func _init():
	VisualServer.set_default_clear_color(Color(0.48,0.48,0.67,1.0))

func scan_players(list):
	for i in list:
		if !i == get_tree().get_network_unique_id():
			spawn_player(i)
	emit_signal("finishedScan")
	
remote func receive_world_data(info):
	loadedWorld = info
	
	for i in loadedWorld["blocks"]:
		place_block(i["id"], i["xpos"], i["ypos"], false)
	
	for i in loadedWorld["walls"]:
		place_block(i["id"], i["xpos"], i["ypos"], true)
		
	#for i in $blockMode.get_children():
		#get_node(i.get_path()).get_node("blockClickable").add_to_group("block")
		#worldData["blocks"].append({"id":get_node(i.get_path()).ID, "xpos":get_node(i.get_path()).position.x, "ypos":get_node(i.get_path()).position.y})
	
	#for i in $wallMode.get_children():
		#i.collides = false
		#get_node(i.get_path()).get_node("blockClickable").add_to_group("wall")
		#worldData["walls"].append({"id":get_node(i.get_path()).ID, "xpos":get_node(i.get_path()).position.x, "ypos":get_node(i.get_path()).position.y})
		
	#print(to_json(worldData))

func _ready():
	yield(self,"finishedScan")
	#yield(self,"finishedRWD")
	rpc("scan_blocks")
	rpc_id(1, "spawn_players", get_tree().get_network_unique_id())
	
func server_place_block(id: int, xpos: int, ypos: int, isWall : bool):
	rpc("receive_placed_block", id, xpos, ypos, isWall)
	
remote func place_block(id : int, xpos : int, ypos : int, isWall : bool):
	var placedBlock = Server.BLOCKS[id].duplicate()
	placedBlock.blockingTexture = Server.BLOCKS[id].blockingTexture
	placedBlock.ID = id
	placedBlock.position = Vector2(xpos, ypos)
	if !isWall:
		$blockMode.add_child(placedBlock)
		placedBlock.get_node("blockClickable").add_to_group("block")
		placedBlock.collides = true
	else:
		$wallMode.add_child(placedBlock)
		placedBlock.get_node("blockClickable").add_to_group("wall")
		placedBlock.collides = false
		
func server_break_block(blockPosition : Vector2, isWall : bool):
	rpc("receive_broke_block", blockPosition, isWall)
		
remote func break_block(blockPosition : Vector2, isWall : bool):
	if !isWall:
		var partics = breakingParticles.instance()
		partics.position = blockPosition
		for i in $blockMode.get_children():
			if get_node(i.get_path()).position == blockPosition:
				get_node(i.get_path()).queue_free()
		add_child(partics)
	else:
		var partics = breakingParticles.instance()
		partics.position = blockPosition
		for i in $wallMode.get_children():
			if get_node(i.get_path()).position == blockPosition:
				get_node(i.get_path()).queue_free()
		add_child(partics)
	
func client_connected_ok():
	print("Callback: client_connected_ok")
	var my_info = { name = "Player", color = "Red"}
	rpc_id(1,"register_player", get_tree().get_network_unique_id(), my_info)

func server_disconnected():
	print("Callback: server_disconnected")

func client_connected_fail():
	print("Callback: client_connected_fail")
	
remote func delete_player(id):
	$players.get_node(str(id)).queue_free()
