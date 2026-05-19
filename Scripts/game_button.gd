extends Node2D

@export var game: SweepMineGame

@onready var background_sprite := $BackgroundSprite
@onready var icon_sprite := $BackgroundSprite/IconSprite
@onready var area_2d: Area2D = $Area2D

var _SPRITE_SIZE= Vector2(84, 84)

var _icon_normal_pos = Vector2(168, 0)
var _icon_win_pos = Vector2(252, 0)
var _icon_lost_pos = Vector2(336, 0)

var _bg_normal_pos = Vector2(0, 0)
var _bg_hovered_pos = Vector2(84, 0)

signal clicked

func _ready() -> void:
	# var texture: AtlasTexture = background_sprite.texture
	# var texture_region = Rect2(_bg_normal_pos, _SPRITE_SIZE)
	#texture.region = texture_region
	
	area_2d.mouse_entered.connect(_on_mouse_entered)
	area_2d.mouse_exited.connect(_on_mouse_exited)
	area_2d.input_event.connect(_on_area_input_event)
	
	game.game_state_changed.connect(_game_state_changed)

func _on_mouse_entered() -> void:
	(background_sprite.texture as AtlasTexture).region = Rect2(_bg_hovered_pos, _SPRITE_SIZE)

func _on_mouse_exited() -> void:
	(background_sprite.texture as AtlasTexture).region = Rect2(_bg_normal_pos, _SPRITE_SIZE)

func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				clicked.emit()

func _game_state_changed(state: SweepMineGame.GAME_STATE) -> void:
	match state:
		SweepMineGame.GAME_STATE.Win:
			(icon_sprite.texture as AtlasTexture).region = Rect2(_icon_win_pos, _SPRITE_SIZE)
		SweepMineGame.GAME_STATE.Lost:
			(icon_sprite.texture as AtlasTexture).region = Rect2(_icon_lost_pos, _SPRITE_SIZE)
		_:
			(icon_sprite.texture as AtlasTexture).region = Rect2(_icon_normal_pos, _SPRITE_SIZE)
