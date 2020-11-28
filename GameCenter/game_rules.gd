extends Node

const PieceResource = preload("res://Piece/Piece.tscn")

# EXPORTED VARIABLES
export var MAP_SIZE = 4
export var PIECE_SIZE = 90
export var PIECES_INTERSPACE = 10

# CONSTANTS
const NEW_PIECE = [2 , 4]
const PIECE_PERC = 0.85 # X% de chances de inserir uma peça com valor 2 e (100-X)% com valor 4
const INPUTS = {
	"ui_right": Vector2.RIGHT,   # Vector2( 1,  0)
	"ui_left": Vector2.LEFT,     # Vector2(-1,  0)
	"ui_up": Vector2.UP,         # Vector2( 0,  1)
	"ui_down": Vector2.DOWN      # Vector2( 0, -1)
}
const PIECES_SETUP = {
	0 : {
		"bg_color": Color(0.8, 0.75, 0.71, 1),
		"font_color": Color(0.47, 0.43, 0.4, 1),
		"font_size": 48
		},
	2 : {
		"bg_color": Color(0.95, 0.95, 0.90, 0.6),
		"font_color": Color(0.47, 0.43, 0.4, 1),
		"font_size": 48
		},
	4 : {
		"bg_color": Color(0.95, 0.95, 0.90, 0.8),
		"font_color": Color(0.47, 0.43, 0.4, 1),
		"font_size": 48
		},
	8 : {
		"bg_color": Color(0.4, 0.7, 0.2, 0.6),
		"font_color": Color(1, 1, 1, 1),
		"font_size": 48
		},
	16 : {
		"bg_color": Color(0.4, 0.7, 0.2, 1),
		"font_color": Color(1, 1, 1, 1),
		"font_size": 48
		},
	32 : {
		"bg_color": Color(0.4, 0.2, 0.9, 0.4),
		"font_color": Color(1, 1, 1, 1),
		"font_size": 48
		},
	64 : {
		"bg_color": Color(0.4, 0.2, 0.9, 1),
		"font_color": Color(1, 1, 1, 1),
		"font_size": 48
		},
	128 : {
		"bg_color": Color(0.9, 0, 0.3, 0.4),
		"font_color": Color(1, 1, 1, 1),
		"font_size": 40
		},
	256 : {
		"bg_color": Color(0.9, 0, 0.3, 0.7),
		"font_color": Color(1, 1, 1, 1),
		"font_size": 40
		},
	512 : {
		"bg_color": Color(0.9, 0, 0.3, 1),
		"font_color": Color(1, 1, 1, 1),
		"font_size": 40
		},
	1024 : {
		"bg_color": Color(0.9, 0.9, 0.1, 0.6),
		"font_color": Color(1, 1, 1, 1),
		"font_size": 32
		},
	2048 : {
		"bg_color": Color(0.9, 0.9, 0.1, 1),
		"font_color": Color(0.47, 0.43, 0.4, 1),
		"font_size": 32
		},
}

# VARIABLES
var occupation_map
var can_insert = false                   # True when a moviment changes the map
var map_changed = true
var score = 0

# SIGNALS
signal new_piece_inserted #unused for now
signal game_over

# FUNÇÕES

# Responsável por inicializar o mapa e inserir duas peças em locais aleatórios
# Para isso, utiliza-se das funções create_map() e 2 insert_new_piece(), respectivamente
# Opcionalmente, mostra os valores do mapa no console
func _ready():
	occupation_map = create_map(MAP_SIZE, MAP_SIZE)
	print_map(occupation_map)
	
	insert_new_piece()
	insert_new_piece()
	
	print_map(occupation_map)

# Responsável por criar um mapa vazio, de tamanho determinado por height e width.
# E o preenche com o seguinte objeto:
#{
#	piece: {
#		value,     # Valor da peça
#		instance   # Instância de Piece que será mostrada em tela
#	},
#	clean          # Booleano que indica se a peça já teve seu valor modificado
#}
# 
func create_map(height, width):
	var map = []
	
	for x in range(height):
		var line = []
		line.resize(width)
		map.append(line)
		for y in range(width):
			map[x][y] = {"piece": {"value": 0, "instance": null}, "clean": true}
			
	return map

# Responsável por imprimir uma representação do mapa no console
func print_map(map):
	var line = ""
	for i in range(MAP_SIZE):
		for j in range(MAP_SIZE):
			line = line + String(map[i][j].piece.value) + " "
		print("[ ", line, "]")
		line = ""
	print("")

# Responsável por inserir uma nova peça no mapa
# Utiliza-se das funções is_position_occupied, is_fully_occupied, no_more_moves e game_over
# É realizada a instância de Piece, que é adicionada ao canvas principal do jogo
# A posição é decidida aleatoriamente e em um local vazio
func insert_new_piece():
	randomize()
	
	var Piece = PieceResource.instance()
	Piece.set_global_position(Vector2(-1000,-1000))
	get_node("GameBG").add_child(Piece)
	var new_piece_value = NEW_PIECE[0] if (randf() <= PIECE_PERC) else NEW_PIECE[1]
	var line = randi() % MAP_SIZE
	var column = randi() % MAP_SIZE
	
	while(is_position_occupied(line, column)):
		line = randi() % MAP_SIZE
		column = randi() % MAP_SIZE
	
	occupation_map[line][column].piece.value = new_piece_value
	occupation_map[line][column].piece.instance = Piece
	
	
	if is_fully_occupied():
		if no_more_moves():
			game_over()

# Responsável por verificar se o mapa está totalmente ocupado
# Não é responsável por determinar se há ou não movimentos válidos disponíveis
func is_fully_occupied():
	var fully_occupied = true
	for line in occupation_map:
		for column in line:
			if !(column.piece.value):
				fully_occupied = false
	return fully_occupied

# Responsável por verificar se uma posição específica está ocupada
func is_position_occupied(line, column):
	return occupation_map[line][column].piece.value

# Responsável por determinar se há ou não movimentos válidos disponíveis
func no_more_moves():
	var no_moves = true
	
	for i in range(MAP_SIZE-1): # [0, 1, 2]
		for j in range(MAP_SIZE): # [0, 1, 2, 3]
			if (occupation_map[i][j].piece.value == occupation_map[i+1][j].piece.value):
				return !no_moves
			if (occupation_map[j][i].piece.value == occupation_map[j][i+1].piece.value):
				return !no_moves
	
	return no_moves

# Responsável por trocar de tela quando o jogo termina, seja por derrota ou vitória
func game_over():
	
	print("Game Over")
	new_game()

# Responsável por lidar com o botão apertado pelo jogador
# Chama a função move_and_insert_pieces quando uma tecla válida é pressionada
func _unhandled_input(event):
	for dir in INPUTS.keys():
		if event.is_action_pressed(dir):
			move_and_insert_pieces(dir)

# Responsável por mover e inserir uma nova peça no mapa
# Para isso, utiliza-se das funções update_map e insert_new_piece, respectivamente
func move_and_insert_pieces(dir):
	can_insert = false
	occupation_map = update_map(dir, occupation_map);
	if can_insert:
		insert_new_piece()
		# Ao fim, a flag map_changed fica com valor true para que a update_screen seja chamada
		map_changed = true
		print_map(occupation_map)

# Responsável por fazer o movimento e "junção das peças" de acordo com um movimento dado.
# Ao final, chama a função clean_pieces
func update_map(direction, map):
	var x_aux
	var y_aux

	# A lógica mostrada nessa condicional se aplica às demais
	if direction == "ui_right":
		for x in range(MAP_SIZE): # range: [0, 1, 2, 3]
			for y in range(MAP_SIZE-2,-1,-1): # range: [2, 1, 0]
				# Move apenas locais no mapa não vazios (peças de valor zero)
				if (map[x][y].piece.value != 0):
					y_aux = y
					# Movimenta apenas peças que não estão na extremidade em relação ao movimento realizado
					# Movimenta as peças às quais seu vizinho (de acordo com o movimento realizado) está vazio
					while(y_aux < MAP_SIZE-1 && map[x][y_aux+1].piece.value == 0):
						y_aux += 1
						map[x][y_aux].piece.value = map[x][y_aux-1].piece.value
						map[x][y_aux].piece.instance = map[x][y_aux-1].piece.instance
						map[x][y_aux-1].piece.value = 0
						can_insert = true
					# Passa para próxima linha ou coluna, pois não há mais movimentos ou "junções" de peças
					# Essa condição é atendida apenas quando a primeira condição do while não é
					if (y_aux == MAP_SIZE-1):
						continue
					# "Une" duas peças, duplicando o valor de uma e zerando o valor da outra
					# Essa condicional acontece apenas quando a condicional de cima falha
					if (map[x][y_aux+1].clean && map[x][y_aux+1].piece.value == map[x][y_aux].piece.value):
						map[x][y_aux+1].piece.value *= 2
						map[x][y_aux+1].clean = false      # Marca a peça como "suja", impedindo novas "junções"
						map[x][y_aux].piece.value = 0
						map[x][y_aux].piece.instance.queue_free()
						score += map[x][y_aux+1].piece.value
						can_insert = true
	
	# Sem comentários abaixo, pois a lógica é equivalente, mudando apenas a sua direção
	if direction == "ui_left":
		for x in range(MAP_SIZE): # range: [0, 1, 2, 3]
			for y in range(1, MAP_SIZE): # range: [1, 2, 3]
				if (map[x][y].piece.value != 0):
					y_aux = y
					while(y_aux > 0 && map[x][y_aux-1].piece.value == 0):
						y_aux -= 1
						map[x][y_aux].piece.value = map[x][y_aux+1].piece.value
						map[x][y_aux].piece.instance = map[x][y_aux+1].piece.instance
						map[x][y_aux+1].piece.value = 0
						can_insert = true
					if (y_aux == 0):
						continue
					if (map[x][y_aux-1].clean && map[x][y_aux-1].piece.value == map[x][y_aux].piece.value):
						map[x][y_aux-1].piece.value *= 2
						map[x][y_aux-1].clean = false
						map[x][y_aux].piece.value = 0
						map[x][y_aux].piece.instance.queue_free()
						score += map[x][y_aux-1].piece.value
						can_insert = true
	
	if direction == "ui_up":
		for y in range(MAP_SIZE): # range: [0, 1, 2, 3]
			for x in range(1, MAP_SIZE): # range: [1, 2, 3]
				if (map[x][y].piece.value != 0):
					x_aux = x
					while(x_aux > 0 && map[x_aux-1][y].piece.value == 0):
						x_aux -= 1
						map[x_aux][y].piece.value = map[x_aux+1][y].piece.value
						map[x_aux][y].piece.instance = map[x_aux+1][y].piece.instance
						map[x_aux+1][y].piece.value = 0
						can_insert = true
					if (x_aux == 0):
						continue
					if (map[x_aux-1][y].clean && map[x_aux-1][y].piece.value == map[x_aux][y].piece.value):
						map[x_aux-1][y].piece.value *= 2
						map[x_aux-1][y].clean = false
						map[x_aux][y].piece.value = 0
						map[x_aux][y].piece.instance.queue_free()
						score += map[x_aux-1][y].piece.value
						can_insert = true
	
	if direction == "ui_down":
		for y in range(MAP_SIZE): # range: [0, 1, 2, 3]
			for x in range(MAP_SIZE-2,-1,-1): # range: [2, 1, 0]
				if (map[x][y].piece.value != 0):
					x_aux = x
					while(x_aux < MAP_SIZE-1 && map[x_aux+1][y].piece.value == 0):
						x_aux += 1
						map[x_aux][y].piece.value = map[x_aux-1][y].piece.value
						map[x_aux][y].piece.instance = map[x_aux-1][y].piece.instance
						map[x_aux-1][y].piece.value = 0
						can_insert = true
					if (x_aux == MAP_SIZE-1):
						continue
					if (map[x_aux+1][y].clean && map[x_aux+1][y].piece.value == map[x_aux][y].piece.value):
						map[x_aux+1][y].piece.value *= 2
						map[x_aux+1][y].clean = false
						map[x_aux][y].piece.value = 0
						map[x_aux][y].piece.instance.queue_free()
						score += map[x_aux+1][y].piece.value
						can_insert = true
	
	clean_pieces(map) # Na próxima rodada, todas as peças devem estar "limpas"
	
	return map

# Responsável por "limpar" todas as peças, possibilitando novas "junções"
func clean_pieces(map):
	for x in range(MAP_SIZE): # [0, 1, 2, 3]
		for y in range(MAP_SIZE): # [0, 1, 2, 3]
			map[x][y].clean = true

# Responsável por atualizar a tela do jogo, na parte visível ao jogador
func update_screen():
	var piece
	var piece_position
	var piece_text
	var piece_text_size
	var piece_text_color
	var piece_bg
	
	for i in range(MAP_SIZE):
		for j in range(MAP_SIZE):
			piece = occupation_map[i][j].piece
			# Apenas peças com valor não nulo são modificadas.
			if (piece.value):
				# piece_position = Vector2(100j + 10, 100i + 10) # 1 Peça + 2 Espaços
				piece_position = Vector2(j * PIECE_SIZE + (j+1) * PIECES_INTERSPACE, i * PIECE_SIZE + (i+1) * PIECES_INTERSPACE)
				piece_text = String(piece.value)
				piece_text_size = PIECES_SETUP[piece.value].font_size
				piece_text_color = PIECES_SETUP[piece.value].font_color
				piece_bg = PIECES_SETUP[piece.value].bg_color
				
				piece.instance.set_position(piece_position)  # Coloca a peça na posição correta
				piece.instance.set_label(piece_text, piece_text_size, piece_text_color) # Muda o valor e seu design
				piece.instance.color = piece_bg # Muda o design da peça
	
	# Ao fim, a flag map_changed fica com valor false para que a update screen não seja chamada novamente
	map_changed = false
	
	# Muda o valor do score na tela do jogo
#	print(get_parent())
	get_parent().get_node("HeaderHBox/ScoresHBox/ScoreBG/ScoreVBox/ScoreValueLabel").text = String(score)

# Responsável por chamar a função update_screen apenas quando o mapa é modificado.
func _process(delta):
	if(map_changed):
		update_screen()

func new_game():
	_ready()
