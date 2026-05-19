extends Node2D

@export_category("Display")
@export var display_align‌ := HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
@export var display_data: int:
	set(value):
		if value > 999: 
			printerr("number more than 1000")
			return
	
		display_data = value
		label.text = str(value).pad_zeros(3)

@onready var label := $Label

func _ready() -> void:
	label.horizontal_alignment = display_align‌

func clear() -> void:
	display_data = 0
