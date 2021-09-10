extends Control

onready var chatLog = get_node("ColorRect/VBoxContainer/RichTextLabel")
onready var inputLabel = get_node("ColorRect/VBoxContainer/HBoxContainer/Label")
onready var inputField = get_node("ColorRect/VBoxContainer/HBoxContainer/LineEdit")
onready var playerType = get_node("ColorRect/VBoxContainer/HBoxContainer/Label")
var user_name = Server.nickname

func _ready():
	playerType.text = '[' + user_name + ']: '
	inputField.connect("text_entered", self, "text_entered")

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			inputField.grab_focus()
		if event.pressed and event.scancode == KEY_ESCAPE:
			inputField.release_focus()

remote func add_message(username : String, text : String):
	$Timer.stop()
	$fade.stop(self)
	modulate = Color(1,1,1,1)
	chatLog.bbcode_text += '[' + '[color=#5bb5cc]' + username + '[/color]' + ']: ' + text + '\n'
	fade()

func text_entered(text):
	if !text == "":
		modulate = Color(1,1,1,1)
		rpc("receive_message", user_name, text)
		inputField.text = ""
		inputField.release_focus()

func _on_LineEdit_focus_entered():
	Server.input = false
	$Timer.stop()
	$fade.stop(self)
	modulate = Color(1,1,1,1)
	$ColorRect/VBoxContainer/HBoxContainer.visible = true

func _on_LineEdit_focus_exited():
	Server.input = true
	fade()
	$ColorRect/VBoxContainer/HBoxContainer.visible = false
	
func fade():
	$Timer.stop()
	modulate = Color(1,1,1,1)
	$Timer.start()
	yield($Timer,"timeout")
	$fade.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 3)
	$fade.start()
