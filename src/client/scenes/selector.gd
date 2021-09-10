extends Area2D

enum PLACE_MODES {BLOCK_MODE, WALL_MODE}

var PLACE_MODE = PLACE_MODES.BLOCK_MODE

var blockHovered = null
var wallHovered = null

var up = false
var right = false
var down = false
var left = false

onready var selectedBlock = clamp(0, 0, Server.BLOCKS.size() - 1)
onready var world = get_tree().get_root().get_node("world")

func _physics_process(delta):
	var mousePos = $TileMap.world_to_map(get_global_mouse_position())
	position = $TileMap.map_to_world(mousePos)
	
	checkHoveredBlocks()
	
	$selectedblock.texture = Server.BLOCKS[selectedBlock].blockingTexture

func checkHoveredBlocks():
	if !get_overlapping_areas().empty():
		var overlap = get_overlapping_areas()
		if overlap.size() == 1:
			for i in overlap.size():
				if overlap[i].is_in_group("block"):
					blockHovered = get_node(overlap[i].get_path()).get_parent()
				else:
					blockHovered = null
				if overlap[i].is_in_group("wall"):
					wallHovered = get_node(overlap[i].get_path()).get_parent()
				else:
					wallHovered = null
		elif overlap.size() == 2:
			for i in overlap.size():
				if overlap[i].is_in_group("block"):
					blockHovered = get_node(overlap[i].get_path()).get_parent()
				if overlap[i].is_in_group("wall"):
					wallHovered = get_node(overlap[i].get_path()).get_parent()
	else:
		blockHovered = null
		wallHovered = null	
		
	if !$cursorUp.get_overlapping_areas().empty():
		var overlap = $cursorUp.get_overlapping_areas()
		if PLACE_MODE == PLACE_MODES.BLOCK_MODE:
			for i in overlap.size():
				if overlap[i].is_in_group("block"):
					up = true
		elif PLACE_MODE == PLACE_MODES.WALL_MODE:
			for i in overlap.size():
				if overlap[i].is_in_group("block") or overlap[i].is_in_group("wall"):
					up = true
	else:
		up = false
		
	if !$cursorRight.get_overlapping_areas().empty():
		var overlap = $cursorRight.get_overlapping_areas()
		if PLACE_MODE == PLACE_MODES.BLOCK_MODE:
			for i in overlap.size():
				if overlap[i].is_in_group("block"):
					right = true
		elif PLACE_MODE == PLACE_MODES.WALL_MODE:
			for i in overlap.size():
				if overlap[i].is_in_group("block") or overlap[i].is_in_group("wall"):
					right = true
	else:
		right = false
		
	if !$cursorDown.get_overlapping_areas().empty():
		var overlap = $cursorDown.get_overlapping_areas()
		if PLACE_MODE == PLACE_MODES.BLOCK_MODE:
			for i in overlap.size():
				if overlap[i].is_in_group("block"):
					down = true
		elif PLACE_MODE == PLACE_MODES.WALL_MODE:
			for i in overlap.size():
				if overlap[i].is_in_group("block") or overlap[i].is_in_group("wall"):
					down = true
	else:
		down = false
		
	if !$cursorLeft.get_overlapping_areas().empty():
		var overlap = $cursorLeft.get_overlapping_areas()
		if PLACE_MODE == PLACE_MODES.BLOCK_MODE:
			for i in overlap.size():
				if overlap[i].is_in_group("block"):
					left = true
		elif PLACE_MODE == PLACE_MODES.WALL_MODE:
			for i in overlap.size():
				if overlap[i].is_in_group("block") or overlap[i].is_in_group("wall"):
					left = true
	else:
		left = false
		
	return str(blockHovered) + ", " + str(wallHovered)
	
func _input(event):
	if Server.input == true:
		if event is InputEventMouseButton:
			if event.is_pressed():
				if event.button_index == BUTTON_WHEEL_UP:
					selectedBlock += 1
					selectedBlock = clamp(selectedBlock, 0, Server.BLOCKS.size() - 1)
				if event.button_index == BUTTON_WHEEL_DOWN:
					selectedBlock -= 1
					selectedBlock = clamp(selectedBlock, 0, Server.BLOCKS.size() - 1)
					
		if event.is_action_pressed("place_block"):
			if PLACE_MODE == PLACE_MODES.BLOCK_MODE:
				if up or right or down or left or !wallHovered == null:
					if blockHovered == null:
						world.server_place_block(selectedBlock, position.x + 16, position.y + 16, false)
							
			elif PLACE_MODE == PLACE_MODES.WALL_MODE:
				if up or right or down or left:
					if wallHovered == null:
						world.server_place_block(selectedBlock, position.x + 16, position.y + 16, true)
						
	if event.is_action_pressed("destroy_block"):
		if PLACE_MODE == PLACE_MODES.BLOCK_MODE:
			if !blockHovered == null:
				world.server_break_block(blockHovered.position, false)
		if PLACE_MODE == PLACE_MODES.WALL_MODE:
			if !wallHovered == null:
				world.server_break_block(wallHovered.position, true)
				
	if event.is_action_pressed("switch_place_mode"):
		if PLACE_MODE == PLACE_MODES.BLOCK_MODE:
			PLACE_MODE = PLACE_MODES.WALL_MODE
			$selectedblock/actualPlaceMode.frame = 1
		elif PLACE_MODE == PLACE_MODES.WALL_MODE:
			PLACE_MODE = PLACE_MODES.BLOCK_MODE
			$selectedblock/actualPlaceMode.frame = 0
