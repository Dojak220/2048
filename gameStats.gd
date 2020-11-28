extends Node

const playerModel = {
	"name": "Jogador",
	"highScore": 0
}

var players = []
var currentPlayer = playerModel
var highScore


#func _ready():

func add_player(playerName):
	if players.size() > 5:
		return {"status": false, "message": "Número de players máximo atingido (máx: 5 players)"}
	print(players.find(playerName))
	if !players.find(playerName):
		return {"status": false, "message": "Já existe um player com esse nome. Tente outro."}
	else:
		var newplayer = playerModel
		newplayer.name = playerName
		newplayer.highScore = 0
		players.append(newplayer)
		currentPlayer = newplayer
		return {"status": true, "player": currentPlayer}

func is_new_record(score):
	if score > highScore:
		highScore = score
		return {"status": true, "response": "Novo recorde!"}
	return {"status": false, "response": ""}
