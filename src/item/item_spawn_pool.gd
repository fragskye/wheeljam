class_name ItemSpawnPool extends Resource

const PAGE: PackedScene = preload("res://prefabs/item/page/page.tscn")

@export var page_start: int = 1
@export var page_end: int = 1
@export var free_spins: int = 0

func create_items() -> Array[Item]:
	var items: Array[Item] = []
	for page_idx: int in range(page_start, page_end + 1):
		var page: Page = PAGE.instantiate()
		var item_data: ItemData = page.data.duplicate()
		if item_data is not PageData:
			push_error("Page's ItemData is not an instance of PageData")
			return items
		var page_data: PageData = item_data as PageData
		page_data.multiplier = float(page_idx)
		page.data = page_data
		items.push_back(page)
	items.shuffle()
	return items
