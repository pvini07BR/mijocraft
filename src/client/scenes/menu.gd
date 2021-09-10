extends Control

onready var nickname = $CenterContainer/VBoxContainer/GridContainer/nick
onready var ip = $CenterContainer/VBoxContainer/GridContainer/ip
onready var port = $CenterContainer/VBoxContainer/GridContainer/port

func _init():
	VisualServer.set_default_clear_color(Color(0.3,0.3,0.3,1))

func _ready():
	nickname.text = Save.save_data["nickname"]
	ip.text = Server.DEFAULT_IP
	port.text = str(Server.DEFAULT_PORT)

func _on_Button_pressed():
	Save.save_data["color"] = Server.playerColor
	Save.save_game()
	join_game()
		
func join_game():
	if !nickname.text == "" or !ip.text == "" or !port.text == "":
		Server.selected_IP = ip.text
		Server.selected_port = int(port.text)
		Server.nickname = nickname.text
		Server._connect_to_server()

func _on_nick_text_entered(new_text):
	join_game()

func _on_nick_text_changed(new_text):
	Save.save_data["nickname"] = nickname.text
	Save.save_game()
	
func kickedPopup(reason : String):
	$Popup/Label.text = "You have been kicked." + '\n' + "Reason: " + reason
	$Popup.rect_position = Vector2(0,0)

func _on_Ok_pressed():
	$Popup.rect_position = Vector2(-1024,-600)
