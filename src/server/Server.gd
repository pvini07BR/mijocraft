extends Node

var network = NetworkedMultiplayerENet.new()
var defaultPort = 6666
var defaultMaxPlayers = 32

var port : int
var maxPlayers : int

var serverRunning = false

var world

var players = {}

func _ready():
	pass
	
func start_server():
	if !serverRunning:
		get_tree().set_network_peer(null)
		network.close_connection()
		network.create_server(port, maxPlayers)
		get_tree().set_network_peer(network)
		network.connect("peer_connected", self, "_player_connected")
		network.connect("peer_disconnected", self, "_player_disconnected")
		
		world = preload("res://scenes/world.tscn").instance()
		get_tree().get_root().call_deferred("add_child", world)
		
		print("Server started")
		serverRunning = true
	
func _player_connected(player_id):
	print("Player: " + str(player_id) + " connected.")
	
func _player_disconnected(player_id):
	for g in players:
		if g == player_id:
			print("Player: " + str(player_id) + " disconnected.")
			for i in get_tree().get_root().get_node("menu").playerList.get_item_count():
				if get_tree().get_root().get_node("menu").playerList.get_item_tooltip(i) == str(player_id):
					get_tree().get_root().get_node("menu").playerList.remove_item(i)
			get_node(world.get_path()).get_node("UI").get_node("chatbox").send_message_from_server("Server", "[color=#fcfa99]" + players[player_id]["nickname"] + " has left." + "[/color]")
			get_tree().get_root().get_node("world").remove_player(player_id)
			rpc("remove_player", player_id)
			players.erase(player_id)
	
remote func send_player_info(id, player_data):
	players[id] = player_data
	rset("players", players)
	rpc("update_players")
	
	get_tree().get_root().get_node("menu").playerList.clear()
	for i in players.size():
		get_tree().get_root().get_node("menu").playerList.add_item(players.values()[i]["nickname"])
		var playerid = str(id)
		get_tree().get_root().get_node("menu").playerList.set_item_tooltip_enabled(i, true)
		get_tree().get_root().get_node("menu").playerList.set_item_tooltip(i, str(players.keys()[i]))

	get_node(world.get_path()).get_node("UI").get_node("chatbox").send_message_from_server("Server", "[color=#fcfa99]" + players[id]["nickname"] + " has joined." + "[/color]")
	
remote func load_world():
	rpc("start_game")
	
func _notification(what):
	if serverRunning == true:
		if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			close_server()
	
func close_server():
	for i in players:
		print(i)
		rpc_id(i,"kicked", "Server closed")
		get_tree().network_peer.disconnect_peer(i)
	players.clear()
	get_tree().get_root().get_node("menu").playerList.clear()
	get_tree().set_network_peer(null)
	get_tree().get_root().get_node("world").queue_free()
	print("Server stopped")
	serverRunning = false
