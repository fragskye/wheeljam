class_name RandomBookShelf extends Node3D

const RANDOM_BOOK: PackedScene = preload("res://assets/models/props/book_store/random_book.tscn")

@export var heights: Array[float] = []
@export var width: float = 0.0
@export var depth: float = 0.0

@export var book_width: float = 0.0
@export var book_spacing_curve: Curve = null

func _ready() -> void:
	var min_x: float = -width * 0.5
	var max_x: float = width * 0.5
	for height: float in heights:
		var x: float = min_x + book_spacing_curve.sample(randf())
		while x <= max_x - book_width:
			var book: RandomBook = RANDOM_BOOK.instantiate()
			add_child(book)
			book.position = Vector3(x, height, depth)
			x += book_width + book_spacing_curve.sample(randf())
