extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	set_value(randi() % 20)

func set_value(value):
	$Label.text = "+ " + str(value)
	$Label.visible = true
#	$Player.play("show_points")

func _on_Palyer_animation_finished(anim_name):
#	$Label.visible = false
	pass
	
func _process(delta):
#	set_value(randi() % 20)
	pass

	
