extends Node2D

# Message Types
enum SUB{CREATE,DELETE,JOIN,LEAVE,LIST}

# Error Codes
enum ERROR{NO_ERROR,NO_SUCH_GAME_ID,CANNOT_JOIN_GAME,INVALID_PASSWORD}

func _ready():
	Server.connect("data_lobby", self, "_on_data")
	Server.connect("user_disconnected",self, "_on_disconnect")

func _on_disconnect(id):
	print("_on_disconnect " + str(id))
	for game in get_children():
		if game.player_list.has(id):
			game.leave_game(id)
			break

func _on_data(id:int, data:Dictionary):
	Debug.log("Lobby", "_on_data")
	match int(data.sub_type):
		SUB.CREATE:
			_create_game(id, str(data.user_name),str(data.password))
		SUB.DELETE:
			_delete_game(id, int(data.game_id))
		SUB.JOIN:
			_join_game(id, str(data.user_name),str(data.password),int(data.game_id))
		SUB.LEAVE:
			_leave_game(id, int(data.game_id))
		SUB.LIST:
			_list_games(id)
		_:	# unknown message
			Debug.log("Lobby", "Unknown message received!!!")
			return

###----------------------------------------------------------------------------
func _create_game(user_id, user_name, password):
	Debug.log("Lobby", "_create_game user_id=" + str(user_id) + " user_name=" + str(user_name) + " password=" + str(password))
	var data: Dictionary = {
		msg_type = Server.MSG.LOBBY,
		sub_type = SUB.CREATE,
		error = 1
	}
	var newGame = load("res://WitchfinderArmy.tscn").instance()
	if !newGame: # return error
		Server.send(user_id,data)
		return
	newGame.set_name(str(user_id)) 
	add_child(newGame)
	newGame.password = password
	data.error = 0
	data.user_id = user_id
	data.game_id = user_id
	Server.send(user_id,data)
	
	
func _delete_game(user_id,game_id):
	Debug.log("Lobby", "_delete_game user_id=" + str(user_id) + " game_id=" + str(game_id))
	var data: Dictionary = {
		msg_type = Server.MSG.LOBBY,
		sub_type = SUB.DELETE,
		error = 1
	}
	if user_id == game_id:
		var game = get_node_or_null(str(game_id))
		if game != null:
			game.end()
			data.error = 0
	Server.send(user_id,data)

func _join_game(user_id,user_name,password,game_id):
	Debug.log("Lobby", "_join_game user_id=" + str(user_id) + " user_name=" + str(user_name) + " password=" + str(password) + " game_id=" + str(game_id))
	var data: Dictionary = {
		msg_type = Server.MSG.LOBBY,
		sub_type = SUB.JOIN,
		error = 1,
		game_id = game_id,
		user_id = user_id
	}
	var game = get_node_or_null(str(game_id))
	if game != null:
		if game.check_password(password):
			data.player_list = game.player_list
			if game.join_game(user_id,user_name) == true:
				data.error = ERROR.NO_ERROR
			else:
				data.error = ERROR.CANNOT_JOIN_GAME
		else:
			data.error = ERROR.INVALID_PASSWORD
	else:
		data.error = ERROR.NO_SUCH_GAME_ID
	Server.send(user_id,data)

func _leave_game(user_id,game_id):
	Debug.log("Lobby", "_leave_game user_id=" + str(user_id) + " game_id=" + str(game_id))
	var data: Dictionary = {
		msg_type = Server.MSG.LOBBY,
		sub_type = SUB.LEAVE,
		error = 1
	}
	var game = get_node_or_null(str(game_id))
	if game != null:
		#if game.check_password(password):
		game.leave_game(user_id)
		data.error = 0
	Server.send(user_id,data)

func _list_games(user_id):
	Debug.log("Lobby", "_list_games user_id=" + str(user_id))
	var data: Dictionary = {
		msg_type = Server.MSG.LOBBY,
		sub_type = SUB.LIST,
		error = 1
	}
	var games = self.get_children()
	var list = []
	for game in games:
		list.append(game.name)
	data.game_list = list
	data.error = 0
	Server.send(user_id,data)
	



