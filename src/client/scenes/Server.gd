extends Node

var rng = RandomNumberGenerator.new()

var nickname : String = "Player"
var playerColor : Color

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 6666

var network = NetworkedMultiplayerENet.new()
var selected_IP
var selected_port

var local_player_id = 0
sync var players = {}
sync var player_data = {}

var world
var BLOCKS = []
var block = preload("res://blockClasses/block.tscn")
var menu = preload("res://scenes/menu.tscn")

var input = true

var connectedPlayers = []

func _init():
	list_blocks()
	rng.randomize()
	playerColor = Color(rng.randf_range(0, 1),rng.randf_range(0, 1),rng.randf_range(0, 1))

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func list_blocks():
	var direcotry = "res://blocks/"
	var files = []
	var dir = Directory.new()
	dir.open(direcotry)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			var blockData = load(direcotry + file)
			var loadedBlock = block.instance()
			loadedBlock.blockingTexture = blockData.blockTexture
			loadedBlock.collides = blockData.hasCollision
			BLOCKS.append(loadedBlock)

	dir.list_dir_end()

	return BLOCKS
	
func _connect_to_server():
	network.close_connection()
	get_tree().disconnect("connected_to_server", self, "_connected_ok")
	get_tree().set_network_peer(null)
	get_tree().connect("connected_to_server", self, "_connected_ok")
	network.create_client(selected_IP, selected_port)
	get_tree().set_network_peer(network)
	yield(network,"peer_connected")
	load_game()
	
func _player_connected(id):
	print("Player: " + str(id) + " connected.")
	
func _player_disconnected(id):
	print("Player: " + str(id) + " disconnected.")
	
func _connected_ok():
	print("Connected to server")
	register_player()
	rpc_id(1,"send_player_info", local_player_id, player_data)
	
func _connected_fail():
	print("Failed to connect")
	if !get_tree().get_root().get_node("menu") == null:
		get_tree().get_root().get_node("menu").kickedPopup("Failed to connect")
	
func _server_disconnected():
	print("Server disconnected")
	network.close_connection()
	get_tree().network_peer.disconnect_peer(local_player_id)
	get_tree().get_root().get_node("world").queue_free()
	var menuInst = menu.instance()
	get_tree().get_root().add_child(menuInst)
	menuInst.kickedPopup("Disconnected from the server")

func register_player():
	local_player_id = get_tree().get_network_unique_id()
	player_data = Save.save_data
	players[local_player_id] = player_data
	
sync func update_players():
	world.scan_players(players)
		
func load_game():
	rpc_id(1, "load_world")
	
sync func start_game():
	world = preload("res://scenes/world.tscn").instance()
	get_tree().get_root().get_node("menu").queue_free()
	get_tree().get_root().add_child(world)
	
remote func kicked(reason):
	get_tree().network_peer.disconnect_peer(local_player_id)
	network.close_connection()
	get_tree().get_root().get_node("world").queue_free()
	var menuInst = menu.instance()
	get_tree().get_root().add_child(menuInst)
	menuInst.kickedPopup(reason)
	print("You have been kicked from the server. Reason: ", reason)
