extends Node

signal camera_rig_updated(camera_rig: PlayerCameraRig)
signal item_picked_up(item: Item)
signal inventory_flushed()
signal battle_begin()
signal battle_end()
signal battle_player_action_previewed(index: int)
signal battle_player_action_selected(index: int, multiplier: float)
signal battle_player_turn_complete()
signal battle_demon_health_changed(percentage: float, absolute: float, delta: float, from_action: bool)
signal battle_demon_verdict(page_mult: float, demon_mult: float, result: float)
signal battle_won()
signal battle_lost()
