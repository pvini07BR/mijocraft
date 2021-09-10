extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 10
const MAXFALLSPEED = 500
const MAXSPEED = 150
const ACCEL = 50

const JUMPFORCE = 225

var noclipMode = false
onready var camera = $camera
onready var nickLabel = $nickname
onready var appearence = $Sprite
var blockSelector = preload("res://scenes/selector.tscn")

var uinst = false
var selector = false

var up = false
var right = false
var down = false
var left = false

var motion = Vector2()

func _ready():
	set_player_name()

func _physics_process(delta):
	if is_network_master():
		if !selector:
			selector = get_tree().get_root().get_node("world").add_child(blockSelector.instance())
			selector = true
		camera.current = true
		if !noclipMode:
			motion.y += GRAVITY
			if motion.y > MAXFALLSPEED:
				motion.y = MAXFALLSPEED
				
			motion.x = clamp(motion.x,-MAXSPEED,MAXSPEED)
			
			if Server.input == true:
				if Input.is_action_pressed("movement_right"):
					motion.x += ACCEL
				elif Input.is_action_pressed("movement_left"):
					motion.x -= ACCEL
				else:
					motion.x = lerp(motion.x,0,0.2)
					
				if is_on_floor():
					if Input.is_action_pressed("movement_jump"):
						motion.y = -JUMPFORCE
				if Input.is_action_just_released("movement_jump"):
					if motion.y < -100:
						motion.y = lerp(motion.y, -100, 0.7)
			else:
				motion.x = lerp(motion.x,0,0.2)

			motion = move_and_slide(motion,UP)
			if !motion.y == 0 and !motion.x == 0:
				$Sprite.rect_rotation += motion.x * delta
			else:
				$Sprite.rect_rotation = 0
			$CollisionShape2D.disabled = false
		else:
			$CollisionShape2D.disabled = true
			$Sprite.rect_rotation = 0
			var prev_motion = motion
			
			if Server.input == true:
				motion.y = int(Input.is_action_pressed("movement_backward")) - int(Input.is_action_pressed("movement_forward"))
				motion.x = int(Input.is_action_pressed("movement_right")) - int(Input.is_action_pressed("movement_left"))

				motion = motion.normalized() * 400
			else:
				motion = Vector2(0,0)
			motion = move_and_slide(lerp(prev_motion, motion, 10 * delta))
			
		rpc_unreliable_id(1, "update_player", global_transform, $Sprite.rect_rotation)
		
remote func update_remote_player(transform, rotation):
	if not is_network_master():
		global_transform = transform
		$Sprite.rect_rotation = rotation
		
func set_player_name():
	nickLabel.text = Server.players[int(name)]["nickname"]
	appearence.color = Color(Server.players[int(name)]["color"])
	
func _input(event):
	if is_network_master():
		if Server.input == true:
			if event.is_action_pressed("respawn"):
				position.y = -100
				get_tree().get_root().get_node("world").get_node("UI").tooltip_appear("Respawned")
			if event.is_action_pressed("toggle_noclip"):
				if !noclipMode:
					noclipMode = true
					get_tree().get_root().get_node("world").get_node("UI").tooltip_appear("No-Clip Mode On")
				elif noclipMode == true:
					noclipMode = false
					get_tree().get_root().get_node("world").get_node("UI").tooltip_appear("No-Clip Mode Off")

			if event.is_action_pressed("zoom_in"):
				$camera.zoom -= Vector2(0.1,0.1)
				get_tree().get_root().get_node("world").get_node("UI").tooltip_appear("Zoom: " + str($camera.zoom))
			if event.is_action_pressed("zoom_out"):
				$camera.zoom += Vector2(0.1,0.1)
				get_tree().get_root().get_node("world").get_node("UI").tooltip_appear("Zoom: " + str($camera.zoom))

			if event.is_action_pressed("debug_key"):
				get_tree().get_root().get_node("world").get_node("UI").get_node("chatbox").add_message("Test", "This is a message being sent.")
