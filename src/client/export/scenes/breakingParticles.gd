extends Position2D

func _ready():
	$CPUParticles2D.emitting = true

func _on_Timer_timeout():
	queue_free()
