extends Node

var Player = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$WelcomeLabel.text = "Oi, " + GameStats.playerName + "! Pronto para jogar?"


func _process(delta):
	pass
