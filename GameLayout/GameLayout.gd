extends Control

signal new_game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_MenuButton_pressed():
#	$ScreenBG/ScreenMargin/ScreenVBox/AcceptDialog.visible = true
	get_tree().change_scene("res://Menu/Menu.tscn")


func _on_NewGameButton_pressed():
	$ScreenBG/ScreenMargin/ScreenVBox/AcceptDialog.visible = true


func _on_AcceptDialog_confirmed():
	pass
