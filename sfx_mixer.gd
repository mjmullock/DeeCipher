extends Node

@onready var coin = $Coin
@onready var gem = $Gem

func play_coin():
	if Globals.play_sfx:
		coin.play()

func play_gem():
	if Globals.play_sfx:
		gem.play()
