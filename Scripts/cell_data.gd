extends Node
class_name CellData

@export var location: Vector2i = Vector2i(-1, -1)
@export var state := CellState.Default
@export var is_mine: bool = false
@export var adjacent_mines: int = 0:
	set(value):
		if value > 8 or value < 0: 
			adjacent_mines = 0
		else:
			adjacent_mines = value

@export var user_define_state := CellState.Default

func check() -> bool:
	if state == user_define_state:
		return true
	else:
		return false

enum CellState{
	Default,
	Revealed,
	Flaged,
	Question,
	Boom,
	Mine
}
