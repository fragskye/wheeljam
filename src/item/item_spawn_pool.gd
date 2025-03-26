class_name ItemSpawnPool extends Resource

const PAGE: PackedScene = preload("res://prefabs/item/page/page.tscn")
const SMUDGE_STICK: PackedScene = preload("res://prefabs/item/smudge_stick/smudge_stick.tscn")

@export var page_start: int = 1
@export var page_end: int = 1
@export var smudge_sticks: int = 0

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
	for smudge_stick_idx: int in smudge_sticks:
		var smudge_stick: SmudgeStick = SMUDGE_STICK.instantiate()
		var item_data: ItemData = smudge_stick.data.duplicate()
		if item_data is not SmudgeStickData:
			push_error("SmudgeStick's ItemData is not an instance of SmudgeStickData")
			return items
		items.push_back(smudge_stick)
	return items
