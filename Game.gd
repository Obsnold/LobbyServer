extends Node
class_name Game

var player_list = {}
var password = ""
var no_players = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


### public functions ----------------------------------------------------------
func join_game(id: int, player_name: String) -> bool:
	var result: bool = true
	if player_list.size() < no_players and player_name != "":
		for player in player_list.keys():
			if player_list[player].name == player_name:
				result = false
				break
		if result == true:
			player_list[id] = {}
			player_list[id].name = player_name
	else:
		result = false
	return result

func leave_game(id: int):
	player_list.erase(id)
	
func send_message(data):
	for player in player_list:
		Server.send(player.id,data)
	
func check_password(pword: String):
	if password == pword:
		return true
	else:
		return false
