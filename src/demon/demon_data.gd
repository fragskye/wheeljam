class_name DemonData extends Resource

@export var faces: Array[DemonFace] = []
@export var default_verdicts: Array[DemonVerdict] = []
@export var lower_mouth_inner_outer_curve: Curve = null
@export var upper_mouth_inner_outer_curve: Curve = null

var verdicts: Array[DemonVerdict] = []

func ready() -> void:
	# Backup a random seed for after this function uses the set seed
	#var random_seed: int = randi()
	#seed(seed)
	
	verdicts = default_verdicts.duplicate()
	verdicts.shuffle()
	
	# Restore non-seeded random behavior
	#seed(random_seed)

func next_phase() -> void:
	pass

func evaluate(index: int) -> DemonVerdict:
	return verdicts[index]
