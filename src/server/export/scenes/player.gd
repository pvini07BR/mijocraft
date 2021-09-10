extends Node2D

remote func update_player(transform, rotation):
	rpc_unreliable("update_remote_player", transform, rotation)
