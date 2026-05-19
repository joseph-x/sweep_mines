extends Node
class_name SweepMineGame

@onready var timer: Timer = $Timer

@export var current_mine_count: int
@export var current_time_seconds: int

## 属性
#region Properties
@export var region_size: Vector2i = Vector2i(9, 9)
@export var mines_count: int = 10

var current_mines: int = 10
var grid: Dictionary[Vector2i, CellData] = {}

var _flag_count: int = 0
var _revealed_count: int = 0
var _first_click_protection: bool = true
var _status: GAME_STATE = GAME_STATE.Idel

var _debug_mode: bool = false
#endregion

## 信号
#region Signals
signal timer_ticked
signal game_state_changed(new_state: GAME_STATE)
signal cell_state_changed(position: Vector2i, state: CellData.CellState)		# 格子被揭开
signal flag_count_changed(count: int)            					# 旗帜数量变化
#endregion

## 游戏逻辑
#region GameLogic
func initialize(size: Vector2i, mines: int) -> void:
	region_size = size
	mines_count = min(mines, size.x * size.y -1)
	
	current_mine_count = mines_count
	current_time_seconds = 0
	reset()


func reset() -> void:
	# 创建空棋盘(不含地雷)
	for x in range(0, region_size.x):
		for y in range(0, region_size.y):
			var cell_data = CellData.new()
			var location = Vector2i(x, y)
			cell_data.location = location
			grid[location] = cell_data
	
	_status = GAME_STATE.Ready
	_flag_count = 0
	_revealed_count = 0
	_first_click_protection = true
	
	var i = randi_range(1,3)
	match i:
		1:
			mines_count = 10
		2:
			mines_count = 20
		3: 
			mines_count = 25
	
	# mines_count = randi_range(10, region_size.x * region_size.y - 10)
	current_mines = mines_count
	current_mine_count = mines_count
	game_state_changed.emit(_status)


func play(start_pos: Vector2i) -> void:
	timer.start()
	_generate_mines(start_pos)
	
	_status = GAME_STATE.Playing
	game_state_changed.emit(_status)

func lost(pos: Vector2i) -> void:
	timer.stop()
	_trigger_game_over(pos)


func win() -> void:
	timer.stop()

	_status = GAME_STATE.Win
	game_state_changed.emit(_status)


	for x in range(0, region_size.x):
		for y in range(0, region_size.y):
			var i = Vector2i(x, y)
			var c: CellData = grid[i]
			
			if c.state == CellData.CellState.Default and c.is_mine == false:
				_reveal_cell(i)

func get_state() -> GAME_STATE:
	return _status

func get_cell_state(pos: Vector2i) -> CellData.CellState:
	return grid[pos].state

func get_cell(pos: Vector2i) -> CellData:
	return grid[pos]

## 用户操作响应
func cell_interact_in(pos: Vector2i) -> void:
	var c = grid[pos]
	if c.is_mine:
		c.state = CellData.CellState.Boom
		cell_state_changed.emit(pos, CellData.CellState.Boom)
		lost(pos)
	else:
		_reveal_cell(pos)

func return_flag() -> void:
	_flag_count = _flag_count - 1
	current_mines = current_mines + 1
	flag_count_changed.emit(current_mines)

func set_cell_state(pos: Vector2i, state: CellData.CellState) -> void:
	var cell: CellData = grid[pos]
	cell.state = state
	
	if state == CellData.CellState.Flaged:
		current_mines = current_mines - 1
		_flag_count = _flag_count + 1
		flag_count_changed.emit(current_mines)
		_check_win_situation()

func _generate_mines(safe_position: Vector2i) -> void:
	var positions: Array[Vector2i] = []
	
	# 收集所有可用位置（排除安全区域）
	for x in range(region_size.x):
		for y in range(region_size.y):
			var pos := Vector2i(x, y)
			# 排除安全位置及其周围8格
			if _first_click_protection and _is_adjacent(pos, safe_position):
				continue
			positions.append(pos)
	
	# 随机打乱并设置地雷
	positions.shuffle()
	for i in range(min(mines_count, positions.size())):
		var pos := positions[i]
		var c: CellData = grid[pos]
		c.is_mine = true
		
		# Debug Display
		if _debug_mode:
			cell_state_changed.emit(pos, CellData.CellState.Mine)
		
	# 计算所有格子的相邻地雷数
	_calculate_adjacent_mines()

func _is_adjacent(pos: Vector2i, safe_position: Vector2i) -> bool:
	return abs(pos.x - safe_position.x) <= 1 && abs(pos.y - safe_position.y) <= 1

func _calculate_adjacent_mines() -> void:
	for x in range(region_size.x):
		for y in range(region_size.y):
			var pos := Vector2i(x, y)
			var current_cell: CellData = grid[pos]
			if current_cell.is_mine:
				continue
			
			var count := 0
			for dir in _DIRECTIONS:
				var neighbor := pos + dir
				if _is_valid_position(neighbor) and grid[neighbor].is_mine:
					count += 1
			current_cell.adjacent_mines = count


func _is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 && pos.y >= 0 && pos.x < region_size.x && pos.y < region_size.y

##
# 揭开格子（递归展开）
# @param position: 起始位置
##
func _reveal_cell(position: Vector2i) -> void:
	var queue: Array[Vector2i] = [position]
	var visited: Array[Vector2i] = []
	
	while not queue.is_empty():
		var pos: Vector2i= queue.pop_front()
		if not visited.has(pos):
			visited.append(pos)
			
			if visited.size() == grid.size():
				break
			
			var cell: CellData= grid[pos]
			
			if cell.state != CellData.CellState.Default:
				continue
				
			cell.state = CellData.CellState.Revealed
			_revealed_count += 1
			cell_state_changed.emit(pos, CellData.CellState.Revealed)
			
			# 只有空白格子（相邻地雷数为0）才继续展开
			if cell.adjacent_mines != 0:
				continue
			
			 # 展开周围8个方向
			for dir in _DIRECTIONS:
				var neighbor_pos := pos + dir
				if _is_valid_position(neighbor_pos):
					queue.append(neighbor_pos)


##
# 触发游戏结束
##
func _trigger_game_over(mine_position: Vector2i) -> void:
	_status = GAME_STATE.Lost
	grid[mine_position].state = CellData.CellState.Boom
	cell_state_changed.emit(mine_position, CellData.CellState.Boom)
	game_state_changed.emit(_status)
	
	# 显示所有地雷位置
	for x in range(region_size.x):
		for y in range(region_size.y):
			if mine_position.x == x and mine_position.y == y:
				continue
			var p := Vector2i(x, y)
			var c = grid[p]
			
			if c.is_mine == true and c.state != CellData.CellState.Flaged:
				c.state = CellData.CellState.Mine
				cell_state_changed.emit(p, CellData.CellState.Mine)

func _check_win_situation() -> void:
	var count: int = 0
	
	if _flag_count == mines_count:
		for x in range(0, region_size.x):
			for y in range(0, region_size.y):
				var i = Vector2i(x, y)
				var c: CellData = grid[i]
				
				if c.is_mine and c.state == CellData.CellState.Flaged:
					count = count + 1
	
	if count == mines_count:
		win()

#endregion


#region Lifecycle
func _ready() -> void:
	timer.wait_time = 1.0	
	timer.timeout.connect(_on_timer_timeout)


#endregion


func _pause() -> void:
	timer.paused = true


func _on_timer_timeout():
	current_time_seconds += 1
	timer_ticked.emit()


enum GAME_STATE {
	Idel,
	Ready,
	Playing,
	Win,
	Lost,
	Pause,
}

# 8个方向偏移量
const _DIRECTIONS: Array[Vector2i] = [
	Vector2i(-1, -1), 
	Vector2i(0, -1), 
	Vector2i(1, -1),
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
	Vector2i(1, 1)
]
