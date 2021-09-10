extends Control

onready var portEnter = $CenterContainer/VBoxContainer/GridContainer/port
onready var maxplayersEnter = $CenterContainer/VBoxContainer/GridContainer/maxPlayers
onready var playerList = $CenterContainer/VBoxContainer/playerList

func _ready():
	playerList.clear()
	portEnter.text = str(Server.defaultPort)
	maxplayersEnter.text = str(Server.defaultMaxPlayers)

func _on_port_text_entered(new_text):
	_start()

func _on_maxPlayers_text_entered(new_text):
	_start()
	
func _process(delta):
	if Server.serverRunning == true:
		$CenterContainer/VBoxContainer/Button.text = "Stop Server"
		portEnter.editable = false
		maxplayersEnter.editable = false
		$CenterContainer/VBoxContainer/playerListText.visible = true
		$CenterContainer/VBoxContainer/playerList.visible = true
	elif Server.serverRunning == false:
		$CenterContainer/VBoxContainer/Button.text = "Start Server"
		portEnter.editable = true
		maxplayersEnter.editable = true
		$CenterContainer/VBoxContainer/playerListText.visible = false
		$CenterContainer/VBoxContainer/playerList.visible = false
	
func _on_Button_pressed():
	if !Server.serverRunning:
		_start()
	else:
		Server.close_server()
	
func _start():
	if !portEnter.text == "" and !maxplayersEnter.text == "" and get_tree().network_peer == null:
		Server.port = int(portEnter.text)
		Server.maxPlayers = int(maxplayersEnter.text)
		Server.start_server()
		
		
