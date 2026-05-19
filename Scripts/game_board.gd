extends Node2D

@export var region_size: Vector2i = Vector2i(9, 9)
@export var game: SweepMineGame
@export var is_user_interactive: bool = true

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var debug_label: Label = $Label

signal on_cell_right_clicked(position: Vector2i)
signal on_cell_left_clicked(position: Vector2i)

var current_hovered_pos := Vector2i(-1, -1)

var Atlas_Normal := Vector2i.ZERO
var Atlas_Hovered := Vector2i(1, 0)
var Atlas_Hint0 := Vector2i(2, 0)
var Atlas_Hint1 := Vector2i(3, 0)
var Atlas_Hint2 := Vector2i(4, 0)
var Atlas_Hint3 := Vector2i(5, 0)
var Atlas_Hint4 := Vector2i(6, 0)
var Atlas_Hint5 := Vector2i(7, 0)
var Atlas_Hint6 := Vector2i(0, 1)
var Atlas_Hint7 := Vector2i(1, 1)
var Atlas_Hint8 := Vector2i(2, 1)
var Atlas_Flaged := Vector2i(3, 1)
var Atlas_Question := Vector2i(4, 1)
var Atlas_Boom := Vector2i(5, 1)
var Atlas_Mine := Vector2i(6, 1)


func _ready() -> void:
	game.game_state_changed.connect(_game_state_changed)
	game.cell_state_changed.connect(_cell_state_changed)

func init() -> void:
	create_tiles()
	is_user_interactive = true

func create_tiles() -> void:
	for x in range(0, region_size.x):
		for y in range(0, region_size.y):
			var cell := Vector2i(x, y)
			tile_map_layer.set_cell(cell, 0, Vector2i.ZERO, 0)


func _unhandled_input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion and is_user_interactive:
		var tile_pos: Vector2i = _get_tile_at_mouse()
		
		if _is_valid_tile(tile_pos):
			if tile_pos != current_hovered_pos:
				if current_hovered_pos != Vector2i(-1, -1):
					_on_cell_exit(current_hovered_pos)
				current_hovered_pos = tile_pos
				_on_cell_enter(current_hovered_pos)

	if event is InputEventMouseButton and is_user_interactive:
		if _is_valid_tile(current_hovered_pos):
			if event.button_index == MOUSE_BUTTON_MASK_LEFT and event.is_pressed():
				on_cell_left_clicked.emit(current_hovered_pos)
			
			if event.button_index == MOUSE_BUTTON_MASK_RIGHT and event.is_pressed():
				on_cell_right_clicked.emit(current_hovered_pos)

	
func _get_tile_at_mouse() -> Vector2i:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var local_mouse_pos: Vector2 = tile_map_layer.to_local(mouse_pos)
	var tile_coords: Vector2i = tile_map_layer.local_to_map(local_mouse_pos)
	
	debug_label.text = str(tile_coords)
	return tile_coords


func _is_valid_tile(pos: Vector2i) -> bool:
	# 检查 tile 坐标是否在有效范围内
	return pos.x >= 0 && pos.y >= 0 && pos.x < region_size.x && pos.y < region_size.y


func _on_cell_enter(cell: Vector2i) -> void:
	# 示例：高亮显示
	if game.get_cell_state(cell) == CellData.CellState.Default:
		tile_map_layer.set_cell(cell, 0, Atlas_Hovered, 0)


func _on_cell_exit(cell: Vector2i) -> void:
	# 示例：恢复原状
	if game.get_cell_state(cell) == CellData.CellState.Default:
		tile_map_layer.set_cell(cell, 0, Atlas_Normal, 0)


func set_tile_cell(cell: Vector2, state: CellData.CellState) -> void:
	_set_tile_cell(cell, state)


func _set_tile_cell(cell: Vector2, state: CellData.CellState) -> void:
		match state:
			CellData.CellState.Default:
				tile_map_layer.set_cell(cell, 0, Atlas_Normal, 0)
			CellData.CellState.Flaged:
				tile_map_layer.set_cell(cell, 0, Atlas_Flaged, 0)
			CellData.CellState.Question:
				tile_map_layer.set_cell(cell, 0, Atlas_Question, 0)
			CellData.CellState.Mine:
				tile_map_layer.set_cell(cell, 0, Atlas_Mine, 0)
			CellData.CellState.Boom:
				tile_map_layer.set_cell(cell, 0, Atlas_Boom, 0)
			CellData.CellState.Revealed:
				var cell_data = game.get_cell(cell)
				match cell_data.adjacent_mines:
					0:
						tile_map_layer.set_cell(cell, 0, Atlas_Hint0)
					1:
						tile_map_layer.set_cell(cell, 0, Atlas_Hint1)
					2:
						tile_map_layer.set_cell(cell, 0, Atlas_Hint2)
					3:
						tile_map_layer.set_cell(cell, 0, Atlas_Hint3)
					4:
						tile_map_layer.set_cell(cell, 0, Atlas_Hint4)
					5:
						tile_map_layer.set_cell(cell, 0, Atlas_Hint5)
					6:
						tile_map_layer.set_cell(cell, 0, Atlas_Hint6)
					7:
						tile_map_layer.set_cell(cell, 0, Atlas_Hint7)
					8:
						tile_map_layer.set_cell(cell, 0, Atlas_Hint8)


func _cell_state_changed(pos: Vector2i, state: CellData.CellState) -> void:
	_set_tile_cell(pos, state)


func _game_state_changed(state: SweepMineGame.GAME_STATE) -> void:
	match state:
		SweepMineGame.GAME_STATE.Win:
			is_user_interactive = false
		SweepMineGame.GAME_STATE.Lost:
			is_user_interactive = false
		_:
			is_user_interactive = true
