extends Game

enum SUB{CHAT,KILL,PEEK,VOTE,PLAYER_LIST,START,END}

# Called when the node enters the scene tree for the first time.
func _ready():
	var err = Server.connect("data_game", self, "_on_data")
	Debug.log("WFG " + name, "connect " + str(err))

func join_game(id: int, player_name: String):
	.join_game(id,player_name)
	player_list[id].type = 0
	player_list[id].ghost = false
	player_list[id].general = false
	Debug.log("WFG " + name,  player_name + " joined game " + name)


func leave_game(id):
	Debug.log("WFG " + name, "send_player_list")
	if player_list.size() != no_players:
		.leave_game(id)
		send_player_list()
	else:
		# the game has already started so end game
		end_game()
		return false

func start_game():
	Debug.log("WFG " + name, "PLAYER_LIST")
	var data: Dictionary = {
		msg_type = Server.MSG.WFG,
		sub_type = SUB.START
	}
	send_message(data)

func end_game():
	Debug.log("WFG " + name, "end_game")
	var data: Dictionary = {
		msg_type = Server.MSG.WFG,
		sub_type = SUB.END
	}
	send_message(data)
	queue_free()
	

func send_broadcast_message(data:Dictionary):
	for player in player_list.keys():
			Server.send(player,data)

func send_message(data:Dictionary):
	for player in player_list.keys():
		Server.send(player,data)
		
func send_player_list():
	Debug.log("WFG " + name, "send_player_list " + str(player_list))
	var data: Dictionary = {
		msg_type = Server.MSG.WFG,
		sub_type = SUB.PLAYER_LIST,
		list = player_list
	}
	send_message(data)

func _on_data(id:int, data:Dictionary):
	Debug.log("WFG " + name, "TESTING")
	Debug.log("WFG " + name, "_on_data " + str(int(data.game_id)) + " " + str(int(data.sub_type)))
	if int(data.game_id) != int(name):
		return
	
	match int(data.sub_type):
		SUB.CHAT:
			send_message(data)
		SUB.KILL:
			send_message(data)
		SUB.PEEK:
			send_message(data)
		SUB.VOTE:
			send_message(data)
		SUB.PLAYER_LIST:
			if data.has("list"):
				for player in data.list:
					player_list[int(player)] = data.list[player]
			send_player_list()
		SUB.START:
			send_message(data)
		SUB.END:
			end_game()
		_:	# unknown message
			Debug.log("WFG " + name, "Unknown message received!!!")
			return


