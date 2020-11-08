extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/CenterContainer/VBoxContainer/PlayerNameTextEdit.text = GameStats.playerName
	pass # Replace with function body.

func _on_StartButton_pressed():
	GameStats.playerName = $MarginContainer/CenterContainer/VBoxContainer/PlayerNameTextEdit.text
	get_tree().change_scene("res://Game.tscn")
