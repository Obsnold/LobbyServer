extends Node
class_name Game

var player_list = {}
var password = ""
var no_players = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


### public functions ----------------------------------------------------------
func join_game(id: int, player_name: String):
	if player_list.size() < no_players:
		player_list[id] = {}
		player_list[id].name = player_name

func leave_game(id: int):
	player_list.erase(id)
	
func send_message(data):
	for player in player_list:
		Server.send(player.id,data)
	
func check_password(pword: String):
	return true
