extends Control

var player_name = "Jogador"
var textEdit
var playersList

# Called when the node enters the scene tree for the first time.
func _ready():
	textEdit = $MarginContainer/CenterContainer/VBoxContainer/VBoxContainer/PlayerNameTextEdit
	playersList = $MarginContainer/CenterContainer/VBoxContainer/VBoxContainer/PlayersList
	textEdit.text = GameStats.currentPlayer.name
	for player in GameStats.players:
		playersList.add_item(player.name)
	print(playersList.items)

#	player_name.text = GameStats.playerName

func _process(delta):
	pass

func _on_StartButton_pressed():
	var response = GameStats.add_player(player_name)
	if !response.status:
		return
	print(response.player)
	get_tree().change_scene("res://GameLayout/GameLayout.tscn")
#	get_tree().change_scene("res://Game.tscn")

func _on_ItemList_item_selected(index):
	textEdit.text = playersList.items[index]

func _on_PlayerNameTextEdit_text_changed():
	player_name = textEdit.text
