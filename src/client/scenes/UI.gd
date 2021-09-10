extends CanvasLayer

func tooltip_appear(text : String):
	$tooltip.text = text
	$tooltipAnim.interpolate_property($tooltip, "modulate", Color(1,1,1,1), Color(1,1,1,0), 3)
	$tooltipAnim.start()
