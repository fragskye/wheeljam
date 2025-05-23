class_name BattleLayer extends CanvasLayer

const WHEEL_SLICE: PackedScene = preload("res://prefabs/ui/wheel_slice.tscn")
const INVENTORY_ITEM: PackedScene = preload("res://prefabs/ui/inventory_item.tscn")
var moves_per_turn: int = 3

signal demon_verdict_anim_finished()

@onready var battle_menu: Control = %BattleMenu
@onready var inventory_carousel: InventoryCarousel = %InventoryCarousel
@onready var wheel: Control = %Wheel
@onready var wheel_slices: Control = %WheelSlices
@onready var wheel_wedges: Control = %WheelWedges
@onready var battle_health: ColorRect = %BattleHealth
@onready var battle_health_fill: ColorRect = %BattleHealthFill
@onready var explanation: HBoxContainer = %Explanation
@onready var page_mult_label: Label = %PageMultLabel
@onready var demon_mult_label: Label = %DemonMultLabel
@onready var result_label: Label = %ResultLabel
@onready var wheel_select_sfx: AudioStreamPlayer2D = %WheelSelectSFX
@onready var wheel_place_sfx: AudioStreamPlayer2D = %WheelPlaceSFX
@onready var wheel_turn_sfx: AudioStreamPlayer2D = %WheelTurnSFX
@onready var smudge_stick_burn_sfx: AudioStreamPlayer2D = %SmudgeStickBurnSFX
@onready var explanation_sfx: AudioStreamPlayer2D = %ExplanationSFX

@export var wheel_slice_count: int = 0

@export var explanation_good_color: Color = Color.WHITE
@export var explanation_neutral_color: Color = Color.WHITE
@export var explanation_bad_color: Color = Color.WHITE

@export var wheel_place_audio: Array[AudioStream] = []
@export var wheel_turn_audio: Array[AudioStream] = []
@export var smudge_stick_burn_audio: Array[AudioStream] = []

var cycles_per_turn: int = 1

var _demon_verdict_queue: Array[Array] = []
var _accepting_new_demon_verdict: bool = true
var _playing_demon_verdict: bool = false
var _battle_ending: bool = false

var _wheel_slices: Array[WheelSlice] = []
var _wheel_wedges: Array[InventoryItem] = []

var _input_state_changed_this_frame: bool = false

var _selected_wheel_slice: int = 0
var _wheel_rotation: int = 0
var _wheel_rotation_visual_offset: float = 0.0

var _needs_more_pages: bool = true
var _moves_in_turn: int = 0

static var _tutorial_step: int = 0
static var _tutorial_bad_seen: bool = false
static var _tutorial_good_seen: bool = false

var actions: Array[String] = ["Bargain", "Beg", "Grieve", "Condemn", "Cry", "Curse"]

func _ready() -> void:
	update_slices()
	battle_menu.hide()
	battle_menu.process_mode = Node.PROCESS_MODE_DISABLED
	InputManager.input_state_changed.connect(_on_input_state_changed)
	SignalBus.battle_player_turn_complete.connect(_on_battle_player_turn_complete)
	SignalBus.battle_demon_health_changed.connect(_on_battle_demon_health_changed)
	SignalBus.battle_begin.connect(_on_battle_begin)
	SignalBus.battle_lost.connect(_on_battle_lost)
	SignalBus.battle_won.connect(_on_battle_won)
	SignalBus.battle_demon_verdict.connect(_on_battle_demon_verdict)
	explanation.modulate = Color.TRANSPARENT
	Global.battle_layer = self
	actions.shuffle()

func rotate_wheel(slices: int) -> void:
	wheel_turn_sfx.stream = wheel_turn_audio.pick_random()
	wheel_turn_sfx.play()
	_wheel_rotation += slices
	while _wheel_rotation < 0:
		_wheel_rotation += wheel_slice_count
	while _wheel_rotation >= wheel_slice_count:
		_wheel_rotation -= wheel_slice_count
	if cycles_per_turn > 0:
		_wheel_rotation_visual_offset = slices * -(360.0 / wheel_slice_count)
	else:
		_wheel_rotation_visual_offset = slices * -(360.0 / wheel_slice_count)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "_wheel_rotation_visual_offset", 0.0, 0.2)
	
func _process(_delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.BATTLE:
		return
	
	#if Input.is_action_just_pressed("debug_test"):
		#rotate_wheel(1)
	
	update_slices()
	
	if _accepting_new_demon_verdict && _demon_verdict_queue.size() > 0:
		_play_demon_verdict()
	
	_input_state_changed_this_frame = false

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	_input_state_changed_this_frame = true
	
	if Global.game_complete:
		return
	
	match old_state:
		InputManager.InputState.BATTLE:
			battle_menu.hide()
			battle_menu.process_mode = Node.PROCESS_MODE_DISABLED
			Global.player.flush_inventory()
	
	match new_state:
		InputManager.InputState.BATTLE:
			Global.player.flush_inventory()
			battle_menu.process_mode = Node.PROCESS_MODE_INHERIT
			battle_menu.show()
			for enemy: Node in get_tree().get_nodes_in_group("enemy"):
				enemy.queue_free()
			if _tutorial_step == 0:
				_tutorial_step += 1
				NotificationLayer.show_toast("The pages say to put them in a wheel arrangement...?")

func _on_close_button_pressed() -> void:
	if InputManager.get_input_state() != InputManager.InputState.BATTLE:
		return
	
	InputManager.pop_input_state()

func update_slices() -> void:
	while wheel_slices.get_child_count() > wheel_slice_count:
		wheel_slices.get_child(wheel_slices.get_child_count() - 1).queue_free()
	while _wheel_slices.size() > wheel_slice_count:
		_wheel_slices.pop_back()
	while wheel_wedges.get_child_count() > wheel_slice_count:
		wheel_wedges.get_child(wheel_wedges.get_child_count() - 1).queue_free()
	while _wheel_slices.size() > wheel_slice_count:
		_wheel_slices.pop_back()
	
	var slice_scale: float = (wheel.size.y * 0.4) / 512.0
	
	for wheel_slice_idx: int in wheel_slice_count:
		var slice_percentage: float = float(wheel_slice_idx) / float(wheel_slice_count)
		var slice_angle: float = slice_percentage * TAU - (PI * 0.5)
		var wedge_percentage: float = float(wheel_slice_idx + _wheel_rotation) / float(wheel_slice_count)
		var wedge_angle: float = (wedge_percentage) * TAU - (PI * 0.5) + deg_to_rad(_wheel_rotation_visual_offset)
		
		var wheel_slice: WheelSlice = null
		
		if wheel_slices.get_child_count() <= wheel_slice_idx:
			wheel_slice = WHEEL_SLICE.instantiate()
			wheel_slice.index = wheel_slice_idx
			wheel_slice.pressed.connect(_on_wheel_slice_pressed)
			_wheel_slices.push_back(wheel_slice)
			wheel_slices.add_child(wheel_slice)
		else:
			wheel_slice = wheel_slices.get_child(wheel_slice_idx)
		
		var wheel_wedge: InventoryItem = null
		
		if wheel_wedges.get_child_count() <= wheel_slice_idx:
			wheel_wedge = INVENTORY_ITEM.instantiate()
			wheel_wedge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_wheel_wedges.push_back(wheel_wedge)
			wheel_wedges.add_child(wheel_wedge)
		else:
			wheel_wedge = wheel_wedges.get_child(wheel_slice_idx)
		
		wheel_slice.position = (wheel.size.y * 0.3) * Vector2(cos(slice_angle), sin(slice_angle))
		wheel_slice.scale = slice_scale * Vector2(1.0, 1.0)
		wheel_slice.angle = slice_angle
		wheel_slice.selected_highlight = _needs_more_pages && wheel_slice_idx == _selected_wheel_slice
		wheel_slice.action_label.text = actions[wheel_slice_idx]
		
		wheel_wedge.position = (wheel.size.y * 0.3) * Vector2(cos(wedge_angle), sin(wedge_angle))
		wheel_wedge.scale = slice_scale * Vector2(1.0, 1.0)

func _on_inventory_carousel_item_pressed(data: ItemData) -> void:
	if !_needs_more_pages && data is SmudgeStickData:
		rotate_wheel(1)
		Global.player.inventory[Global.player.inventory.find(data)] = null
		inventory_carousel.update_inventory_items()
		smudge_stick_burn_sfx.stream = smudge_stick_burn_audio.pick_random()
		smudge_stick_burn_sfx.play()
		return
	
	if data is not PageData:
		return
	
	var target_wedge: int = _selected_wheel_slice - _wheel_rotation
	while target_wedge < 0:
		target_wedge += wheel_slice_count
	while target_wedge >= wheel_slice_count:
		target_wedge -= wheel_slice_count
	if _wheel_wedges[target_wedge].data == null:
		_wheel_wedges[target_wedge].set_item(data)
		Global.player.inventory[Global.player.inventory.find(data)] = null
		inventory_carousel.update_inventory_items()
		wheel_place_sfx.stream = wheel_place_audio.pick_random()
		wheel_place_sfx.play()
		
		select_empty()

func select_empty() -> void:
	var empty_slot: bool = false
	var empty_slot_idx: int = 0
	for wheel_slice_idx: int in wheel_slice_count:
		if wheel_slice_idx >= _wheel_wedges.size():
			continue
		var wheel_wedge: InventoryItem = _wheel_wedges[wheel_slice_idx]
		if wheel_wedge.data == null:
			empty_slot = true
			empty_slot_idx = wheel_slice_idx + _wheel_rotation
			break
	if !empty_slot:
		if _wheel_wedges.size() >= wheel_slice_count:
			_needs_more_pages = false
		Global.player.flush_inventory()
	else:
		while empty_slot_idx < 0:
			empty_slot_idx += wheel_slice_count
		while empty_slot_idx >= wheel_slice_count:
			empty_slot_idx -= wheel_slice_count
		_selected_wheel_slice = empty_slot_idx

func _on_wheel_slice_pressed(index: int) -> void:
	if get_wedge_page(index) == null:
		wheel_select_sfx.play()
		_selected_wheel_slice = index
	if !_needs_more_pages:
		_moves_in_turn += 1
		_wheel_slices[index].disabled = true
		var page: PageData = get_wedge_page(index)
		SignalBus.battle_player_action_selected.emit(index, page.multiplier)
		page.pending_burn = true
		rotate_wheel(cycles_per_turn)
		if _moves_in_turn >= moves_per_turn:
			SignalBus.battle_player_turn_complete.emit()
			_moves_in_turn = 0

func _on_battle_player_turn_complete() -> void:
	var pages_burned: int = 0
	var pages_needed: int = 0
	for wheel_slice_idx: int in wheel_slice_count:
		var wheel_slice: WheelSlice = _wheel_slices[wheel_slice_idx]
		wheel_slice.disabled = false
		
		var wheel_wedge: InventoryItem = _wheel_wedges[wheel_slice_idx]
		var page: PageData = wheel_wedge.data as PageData
		if page.pending_burn:
			if page.burning:
				wheel_wedge.set_item(null)
				_selected_wheel_slice = wheel_slice_idx + _wheel_rotation
				while _selected_wheel_slice < 0:
					_selected_wheel_slice += wheel_slice_count
				while _selected_wheel_slice >= wheel_slice_count:
					_selected_wheel_slice -= wheel_slice_count
				pages_burned += 1
				_needs_more_pages = true
				pages_needed += 1
			else:
				page.burning = true
				page.pending_burn = false
	if _needs_more_pages && !_battle_ending:
		var page_count: int = 0
		for item: ItemData in Global.player.inventory:
			if item is PageData:
				page_count += 1
		if page_count < pages_needed:
			SignalBus.battle_lost.emit()
		else:
			if pages_burned == 1:
				NotificationLayer.show_toast("That page burned up. I need a new one...")
			else:
				NotificationLayer.show_toast("Those pages burned up. I need new ones...")

func get_wedge_page(slice: int) -> PageData:
	slice -= _wheel_rotation
	while slice < 0:
		slice += wheel_slice_count
	while slice >= wheel_slice_count:
		slice -= wheel_slice_count
	return _wheel_wedges[slice].data as PageData

func _on_battle_demon_health_changed(percentage: float, _absolute: float, _delta: float, _from_action: bool) -> void:
	battle_health_fill.custom_minimum_size.x = battle_health.size.x * percentage

func _on_battle_begin() -> void:
	var page_count: int = 0
	for item: ItemData in Global.player.inventory:
		if item is PageData:
			page_count += 1
	if page_count < wheel_slice_count:
		SignalBus.battle_lost.emit() # player started a battle without enough pages...

func _on_battle_lost() -> void:
	_battle_ending = true
	# REALLY??? THIS IS HOW I DISABLE A CONTROL WITHOUT REMOVING IT FROM THE HIERARCHY AND MESSING UP MY LAYOUT???
	wheel.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])
	wheel.process_mode = Node.PROCESS_MODE_DISABLED
	wheel.modulate = Color.TRANSPARENT
	inventory_carousel.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])
	inventory_carousel.process_mode = Node.PROCESS_MODE_DISABLED
	inventory_carousel.modulate = Color.TRANSPARENT
	SignalBus.battle_end.emit()
	InputManager.switch_input_state(InputManager.InputState.GAME_OVER)

func _on_battle_won() -> void:
	_battle_ending = true
	wheel.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])
	wheel.process_mode = Node.PROCESS_MODE_DISABLED
	wheel.modulate = Color.TRANSPARENT
	inventory_carousel.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])
	inventory_carousel.process_mode = Node.PROCESS_MODE_DISABLED
	inventory_carousel.modulate = Color.TRANSPARENT
	
	if _playing_demon_verdict:
		await demon_verdict_anim_finished
	
	await SignalBus.demon_animation_end
	
	SignalBus.battle_end.emit()
	InputManager.pop_input_state()

func _on_battle_demon_verdict(page_mult: float, demon_mult: float, result: float) -> void:
	_demon_verdict_queue.push_back([page_mult, demon_mult, result])
	if _accepting_new_demon_verdict:
		_play_demon_verdict()

func _play_demon_verdict() -> void:
	_accepting_new_demon_verdict = false
	_playing_demon_verdict = true
	var demon_verdict: Array = _demon_verdict_queue.pop_front()
	var page_mult: float = demon_verdict[0]
	var demon_mult: float = demon_verdict[1]
	var result: float = demon_verdict[2]
	
	explanation.modulate = Color.WHITE
	page_mult_label.hide()
	demon_mult_label.hide()
	result_label.hide()
	
	page_mult_label.text = str(page_mult)
	demon_mult_label.text = str(demon_mult)
	result_label.text = str(result)
	
	# is there seriously no built-in format specifier for this?
	if page_mult_label.text.ends_with(".0"):
		page_mult_label.text = page_mult_label.text.substr(0, page_mult_label.text.length() - 2)
	if demon_mult_label.text.ends_with(".0"):
		demon_mult_label.text = demon_mult_label.text.substr(0, demon_mult_label.text.length() - 2)
	if result_label.text.ends_with(".0"):
		result_label.text = result_label.text.substr(0, result_label.text.length() - 2)
	
	var demon_mult_pitch: float = 1.0
	
	if demon_mult > 0:
		demon_mult_pitch = 1.05
		demon_mult_label.modulate = explanation_good_color
	elif demon_mult < 0:
		demon_mult_pitch = 0.95
		demon_mult_label.modulate = explanation_bad_color
	else:
		demon_mult_label.modulate = explanation_neutral_color
	
	var result_pitch: float = 1.0
	
	if result > 0:
		result_pitch = 1.1
		result_label.modulate = explanation_good_color
	elif result < 0:
		result_pitch = 0.9
		result_label.modulate = explanation_bad_color
	else:
		result_label.modulate = explanation_neutral_color
	
	var page_mult_label_pos: Vector2 = page_mult_label.global_position
	var demon_mult_label_pos: Vector2 = demon_mult_label.global_position
	
	var step_duration: float = 0.4
	
	explanation_sfx.pitch_scale = 1.0
	explanation_sfx.play()
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	page_mult_label.global_position = page_mult_label_pos + Vector2(-40.0, 0.0)
	page_mult_label.scale = Vector2(1.6, 1.6)
	tween.tween_property(page_mult_label, "visible", true, 0.0)
	tween.tween_property(page_mult_label, "global_position", page_mult_label_pos, step_duration)
	tween.parallel().tween_property(page_mult_label, "scale", Vector2.ONE, step_duration)
	demon_mult_label.global_position = demon_mult_label_pos + Vector2(0.0, -40.0)
	demon_mult_label.scale = Vector2(1.6, 1.6)
	tween.tween_property(explanation_sfx, "pitch_scale", demon_mult_pitch, 0.0)
	tween.tween_callback(explanation_sfx.play)
	tween.tween_property(demon_mult_label, "visible", true, 0.0)
	tween.tween_property(demon_mult_label, "global_position", demon_mult_label_pos, step_duration)
	tween.parallel().tween_property(demon_mult_label, "scale", Vector2.ONE, step_duration)
	result_label.scale = Vector2(2.2, 2.2)
	tween.tween_property(explanation_sfx, "pitch_scale", result_pitch, 0.0)
	tween.tween_callback(explanation_sfx.play)
	tween.tween_property(result_label, "visible", true, 0.0)
	tween.tween_property(result_label, "scale", Vector2(1.6, 1.6), step_duration)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(explanation, "modulate", Color.TRANSPARENT, 0.6)
	await tween.finished
	
	if _demon_verdict_queue.size() == 0:
		demon_verdict_anim_finished.emit()
	
	_playing_demon_verdict = false
	_accepting_new_demon_verdict = true
