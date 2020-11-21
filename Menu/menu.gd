extends Control

var player_name

# Called when the node enters the scene tree for the first time.
func _ready():
	player_name = $MarginContainer/CenterContainer/VBoxContainer/PlayerNameTextEdit
	player_name.text = "Player_" + String(OS.get_system_time_secs())
#	player_name.text = GameStats.playerName

func _on_StartButton_pressed():
	GameStats.playerName = $MarginContainer/CenterContainer/VBoxContainer/PlayerNameTextEdit.text
	get_tree().change_scene("res://GameLayout/GameLayout.tscn")
#	get_tree().change_scene("res://Game.tscn")
