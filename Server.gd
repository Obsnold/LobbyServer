extends Node

var PORT = 3000
var MAX_PLAYERS = 100
var _server = WebSocketServer.new()

enum MSG{LOBBY,WFG}
#message header
# message type (LOBBY WFG or other game)
# message subcode

signal user_disconnected(id)
signal user_connected(id)
signal user_closed_connection(id)
signal data_lobby(id,data)
signal data_game(id,data)

func _ready():
	_server.connect("client_connected", self, "_client_connected")
	_server.connect("client_disconnected", self, "_client_disconnected")
	_server.connect("client_close_request", self, "_close_request")
	_server.connect("data_received", self, "_on_data")
	var err = _server.listen(PORT)
	if err != OK:
		Debug.log( "Server", "Unable to start server")
		set_process(false)

func _process(_delta):
	_server.poll()


### PUBLIC FUNCTIONS ----------------------------------------------------------
func send(id,data):
	var packet: PoolByteArray = JSON.print(data).to_utf8()
	_server.get_peer(id).put_packet(packet)


### SERVER FUNCTIONS ----------------------------------------------------------
func _client_connected(id, _protocol):
	Debug.log( "Server", 'Client ' + str(id) + ' connected to Server')
	emit_signal("user_connected",id)

func _close_request(id, _code, _reason):
	Debug.log( "Server", 'Client ' + str(id) + ' _close_request')
	emit_signal("user_closed_connection",id)

func _client_disconnected(id, _was_clean_close):
	Debug.log( "Server", 'Client ' + str(id) + ' disconnected')
	emit_signal("user_disconnected",id)

func _on_data(id):
	var packet: PoolByteArray = _server.get_peer(id).get_packet()
	var data: Dictionary = JSON.parse(packet.get_string_from_utf8()).result
	match(int(data.msg_type)):
		MSG.LOBBY:
			Debug.log( "Server", "data_lobby")
			emit_signal("data_lobby",id,data)
		MSG.WFG:
			Debug.log( "Server", "data_game")
			emit_signal("data_game",id,data)
		_:	# unknown message
			Debug.log( "Server", "Unknown message received!!!")
			return

