extends StaticBody2D

export var blockingTexture : Texture
export var collides : bool = true
export var ID : int = 0
var clickableArea = preload("res://scenes/blockClickable.tscn")

func _ready():
	var click = clickableArea.instance()
	click.connect("area_entered",self,"_on_clickable_area_entered")
	$texture.texture = blockingTexture
	
func _process(delta):
	$collision.disabled = not collides

func _on_clickable_area_entered(area):
	if self.is_in_group("block") and area.is_in_group("block") or self.is_in_group("wall") and area.is_in_group("wall"):
		get_node(area.get_path()).get_parent().queue_free()
