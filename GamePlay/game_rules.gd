extends Node

const PieceResource = preload("res://Piece/Piece.tscn")

# EXPORTED VARIABLES
export var MAP_SIZE = 4
export var PIECE_SIZE = 90
export var PIECES_INTERSPACE = 10

# CONSTANTS
const NEW_PIECE = [2 , 4]
const PIECE_PERC = 0.85
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

# FUNÇÕES
func _ready():
	occupation_map = create_map(MAP_SIZE, MAP_SIZE)
	print_map()
	
	insert_new_piece()
	insert_new_piece()
	
	print_map()

func create_map(height, width):
	var map = []
	
	for x in range(height):
		var line = []
		line.resize(width)
		map.append(line)
		for y in range(width):
			map[x][y] = {"piece": {"value": 0, "instance": null}, "clean": true}
			
	return map

func print_map():
	var line = ""
	for i in range(MAP_SIZE):
		for j in range(MAP_SIZE):
			line = line + String(occupation_map[i][j].piece.value) + " "
		print("[ ", line, "]")
		line = ""
	print("")

func insert_new_piece():
	if is_fully_occupied():
		return
	
	randomize()
	
	#get_child(snake_size+1).connect("body_hit", self, "_on_SnakeBody_hit")
	
	var Piece = PieceResource.instance()
	Piece.set_global_position(Vector2(-1000,-1000))
	get_node("ScreenBG/ScreenMargin/ScreenVBox/GameCenter/GameBG").add_child(Piece)
	var new_piece_value = NEW_PIECE[0] if (randf() <= PIECE_PERC) else NEW_PIECE[1]
	var line = randi() % MAP_SIZE
	var column = randi() % MAP_SIZE
	
	while(is_position_occupied(line, column)):
		line = randi() % MAP_SIZE
		column = randi() % MAP_SIZE
	
	occupation_map[line][column].piece.value = new_piece_value
	occupation_map[line][column].piece.instance = Piece
	
	if is_fully_occupied():
		print("Mapa cheio. Se não houver combinações possíveis... Game over")

func is_fully_occupied():
	var fully_occupied = true
	for line in occupation_map:
		for column in line:
			if !(column.piece.value):
				fully_occupied = false
	return fully_occupied

func is_position_occupied(line, column):
	return occupation_map[line][column].piece.value

func _unhandled_input(event):
	for dir in INPUTS.keys():
		if event.is_action_pressed(dir):
			can_insert = false
			update_map(dir);
			if can_insert:
				insert_new_piece()
				map_changed = true
			print_map()

func update_map(direction):
	var x_aux
	var y_aux

	if direction == "ui_right":
		for x in range(MAP_SIZE): # range: [0, 1, 2, 3]
			for y in range(MAP_SIZE-2,-1,-1): # range: [2, 1, 0]
				if (occupation_map[x][y].piece.value != 0):
					y_aux = y
					while(y_aux < MAP_SIZE-1 && occupation_map[x][y_aux+1].piece.value == 0):
						y_aux += 1
						occupation_map[x][y_aux].piece.value = occupation_map[x][y_aux-1].piece.value
						occupation_map[x][y_aux].piece.instance = occupation_map[x][y_aux-1].piece.instance
						occupation_map[x][y_aux-1].piece.value = 0
						can_insert = true
					if (y_aux == MAP_SIZE-1):
						continue
					if (occupation_map[x][y_aux+1].clean && occupation_map[x][y_aux+1].piece.value == occupation_map[x][y_aux].piece.value):
						occupation_map[x][y_aux+1].piece.value *= 2 # It's necessary to change this piece's label
						occupation_map[x][y_aux+1].clean = false
						occupation_map[x][y_aux].piece.value = 0 # It's necessary to uninstance this piece
						occupation_map[x][y_aux].piece.instance.queue_free()
						score += occupation_map[x][y_aux+1].piece.value
						can_insert = true
	
	if direction == "ui_left":
		for x in range(MAP_SIZE): # range: [0, 1, 2, 3]
			for y in range(1, MAP_SIZE): # range: [1, 2, 3]
				if (occupation_map[x][y].piece.value != 0):
					y_aux = y
					while(y_aux > 0 && occupation_map[x][y_aux-1].piece.value == 0):
						y_aux -= 1
						occupation_map[x][y_aux].piece.value = occupation_map[x][y_aux+1].piece.value
						occupation_map[x][y_aux].piece.instance = occupation_map[x][y_aux+1].piece.instance
						occupation_map[x][y_aux+1].piece.value = 0
						can_insert = true
					if (y_aux == 0):
						continue
					if (occupation_map[x][y_aux-1].clean && occupation_map[x][y_aux-1].piece.value == occupation_map[x][y_aux].piece.value):
						occupation_map[x][y_aux-1].piece.value *= 2 # It's necessary to change this piece's label
						occupation_map[x][y_aux-1].clean = false
						occupation_map[x][y_aux].piece.value = 0 # It's necessary to uninstance this piece
						occupation_map[x][y_aux].piece.instance.queue_free()
						score += occupation_map[x][y_aux-1].piece.value
						can_insert = true
	
	if direction == "ui_up":
		for y in range(MAP_SIZE): # range: [0, 1, 2, 3]
			for x in range(1, MAP_SIZE): # range: [1, 2, 3]
				if (occupation_map[x][y].piece.value != 0):
					x_aux = x
					while(x_aux > 0 && occupation_map[x_aux-1][y].piece.value == 0):
						x_aux -= 1
						occupation_map[x_aux][y].piece.value = occupation_map[x_aux+1][y].piece.value
						occupation_map[x_aux][y].piece.instance = occupation_map[x_aux+1][y].piece.instance
						occupation_map[x_aux+1][y].piece.value = 0
						can_insert = true
					if (x_aux == 0):
						continue
					if (occupation_map[x_aux-1][y].clean && occupation_map[x_aux-1][y].piece.value == occupation_map[x_aux][y].piece.value):
						occupation_map[x_aux-1][y].piece.value *= 2 # It's necessary to change this piece's label
						occupation_map[x_aux-1][y].clean = false
						occupation_map[x_aux][y].piece.value = 0 # It's necessary to uninstance this piece
						occupation_map[x_aux][y].piece.instance.queue_free()
						score += occupation_map[x_aux-1][y].piece.value
						can_insert = true
	
	if direction == "ui_down":
		for y in range(MAP_SIZE): # range: [0, 1, 2, 3]
			for x in range(MAP_SIZE-2,-1,-1): # range: [2, 1, 0]
				if (occupation_map[x][y].piece.value != 0):
					x_aux = x
					while(x_aux < MAP_SIZE-1 && occupation_map[x_aux+1][y].piece.value == 0):
						x_aux += 1
						occupation_map[x_aux][y].piece.value = occupation_map[x_aux-1][y].piece.value
						occupation_map[x_aux][y].piece.instance = occupation_map[x_aux-1][y].piece.instance
						occupation_map[x_aux-1][y].piece.value = 0
						can_insert = true
					if (x_aux == MAP_SIZE-1):
						continue
					if (occupation_map[x_aux+1][y].clean && occupation_map[x_aux+1][y].piece.value == occupation_map[x_aux][y].piece.value):
						occupation_map[x_aux+1][y].piece.value *= 2 # It's necessary to change this piece's label
						occupation_map[x_aux+1][y].clean = false
						occupation_map[x_aux][y].piece.value = 0 # It's necessary to uninstance this piece
						occupation_map[x_aux][y].piece.instance.queue_free()
						score += occupation_map[x_aux+1][y].piece.value
						can_insert = true
	print(score)
	clean_map()

func clean_map():
	for x in range(MAP_SIZE): # [0, 1, 2, 3]
			for y in range(MAP_SIZE): # [0, 1, 2, 3]
				occupation_map[x][y].clean = true

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
			
			if (piece.instance && piece.value):
				piece_position = Vector2(j * PIECE_SIZE + (j+1) * PIECES_INTERSPACE, (i) * PIECE_SIZE + (i+1) * PIECES_INTERSPACE)
				piece_text = String(piece.value)
				piece_text_size = PIECES_SETUP[piece.value].font_size
				piece_text_color = PIECES_SETUP[piece.value].font_color
				piece_bg = PIECES_SETUP[piece.value].bg_color
				
				piece.instance.set_position(piece_position)
				piece.instance.set_label(piece_text, piece_text_size, piece_text_color)
				piece.instance.color = piece_bg

	map_changed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(map_changed):
		update_screen()
	pass
