extends Node2D

# Message Types
enum SUB{CREATE,DELETE,JOIN,LEAVE,LIST}

func _ready():
	Server.connect("data_lobby", self, "_on_data")

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
			game.join_game(user_id,user_name)
			data.error = 0
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
		game.leave(user_id)
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
	



