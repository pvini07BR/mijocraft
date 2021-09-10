extends Node

remote func receive_message(username : String, text : String):
	rpc("add_message", username, text)
	
func send_message_from_server(username : String, text : String):
	rpc("add_message", username, text)
