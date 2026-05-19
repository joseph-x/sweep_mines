extends Node2D

@onready var game_board := $UICanvasLayer/GameBoard
@onready var mine_display := $UICanvasLayer/MineDigitalDisplay
@onready var time_display := $UICanvasLayer/TimeDigitalDisplay
@onready var game_button := $UICanvasLayer/GameButton
@onready var game: SweepMineGame = $Game
@onready var win_popup_canvas_layer: CanvasLayer = $WinPopupCanvasLayer
@onready var lost_popup_canvas_layer: CanvasLayer = $LostPopupCanvasLayer
@onready var paper_particles: GPUParticles2D = $WinPopupCanvasLayer/WinLabel/PaperBurst

var time_seconds: int = 0

func _ready() -> void:
	_game_init()
	
	# Game Core
	game.timer_ticked.connect(_update_time_seconds_display)
	game.flag_count_changed.connect(_update_mine_count_display)
	game.game_state_changed.connect(_game_state_changed)
	
	# Game Button
	game_button.clicked.connect(_on_game_button_clicked)
	
	# Game Board
	game_board.on_cell_right_clicked.connect(_on_cell_right_clicked)
	game_board.on_cell_left_clicked.connect(_on_cell_left_clicked)


func _update_time_seconds_display():
	time_seconds = game.current_time_seconds
	time_display.display_data = time_seconds

func _update_mine_count_display(count: int) -> void:
	mine_display.display_data = count


func _on_game_button_clicked():
	_game_init()
	

func _game_init() -> void:
	# Inital Game
	game.initialize(Vector2i(9,9), 10)
	time_seconds = game.current_time_seconds

	# Inital UI
	game_board.init()
	mine_display.display_data = game.current_mine_count
	time_display.display_data = time_seconds
	
	

func _on_cell_left_clicked(cell: Vector2i) -> void:
	if game.get_state() == SweepMineGame.GAME_STATE.Ready:
		game.play(cell)
	
	game.cell_interact_in(cell)

func _on_cell_right_clicked(cell: Vector2i) -> void:
	match game.get_cell_state(cell):
		CellData.CellState.Default:
			game_board.set_tile_cell(cell, CellData.CellState.Flaged)
			game.set_cell_state(cell, CellData.CellState.Flaged)
		CellData.CellState.Flaged:
			game_board.set_tile_cell(cell, CellData.CellState.Question)
			game.return_flag()
			game.set_cell_state(cell, CellData.CellState.Question)
		CellData.CellState.Question:
			game_board.set_tile_cell(cell, CellData.CellState.Default)
			game.set_cell_state(cell, CellData.CellState.Default)

func _game_state_changed(state: SweepMineGame.GAME_STATE) -> void:
	match state:
		SweepMineGame.GAME_STATE.Win:
			win_popup_canvas_layer.show()
			paper_particles.brust()
		SweepMineGame.GAME_STATE.Lost:
			lost_popup_canvas_layer.show()
		_:
			win_popup_canvas_layer.hide()
			lost_popup_canvas_layer.hide()
