class_name DemonFace extends Resource

@export_group("Eyes", "eyes_")
@export var eyes_inner: float = -0.25
@export var eyes_outer: float = 0.25
@export var eyes_height: float = 0.0
@export var eyes_tilt: float = 0.0
@export_group("Lower Mouth", "lower_mouth_")
@export var lower_mouth_scale: float = 1.0
@export var lower_mouth_inner_bottom: float = -0.25
@export var lower_mouth_inner_top: float = 0.25
@export var lower_mouth_outer_bottom: float = -0.25
@export var lower_mouth_outer_top: float = 0.25
@export_group("Upper Mouth", "upper_mouth_")
@export var upper_mouth_scale: float = 1.0
@export var upper_mouth_inner_bottom: float = -0.25
@export var upper_mouth_inner_top: float = 0.25
@export var upper_mouth_outer_bottom: float = -0.25
@export var upper_mouth_outer_top: float = 0.25
@export_group("Variance")
@export var variance: float = 0.0
@export var variance_spike: float = 0.0
@export var variance_spike_duration_min: int = 0
@export var variance_spike_duration_max: int = 0
@export var variance_spike_delay_min: float = 0.0
@export var variance_spike_delay_max: float = 0.0

func lerp(to: DemonFace, weight: float) -> DemonFace:
	var result: DemonFace = DemonFace.new()
	result.eyes_inner = lerpf(eyes_inner, to.eyes_inner, weight)
	result.eyes_outer = lerpf(eyes_outer, to.eyes_outer, weight)
	result.eyes_height = lerpf(eyes_height, to.eyes_height, weight)
	result.eyes_tilt = lerpf(eyes_tilt, to.eyes_tilt, weight)
	result.lower_mouth_scale = lerpf(lower_mouth_scale, to.lower_mouth_scale, weight)
	result.lower_mouth_inner_bottom = lerpf(lower_mouth_inner_bottom, to.lower_mouth_inner_bottom, weight)
	result.lower_mouth_inner_top = lerpf(lower_mouth_inner_top, to.lower_mouth_inner_top, weight)
	result.lower_mouth_outer_bottom = lerpf(lower_mouth_outer_bottom, to.lower_mouth_outer_bottom, weight)
	result.upper_mouth_outer_top = lerpf(lower_mouth_outer_top, to.lower_mouth_outer_top, weight)
	result.upper_mouth_scale = lerpf(upper_mouth_scale, to.upper_mouth_scale, weight)
	result.upper_mouth_inner_bottom = lerpf(upper_mouth_inner_bottom, to.upper_mouth_inner_bottom, weight)
	result.upper_mouth_inner_top = lerpf(upper_mouth_inner_top, to.upper_mouth_inner_top, weight)
	result.upper_mouth_outer_bottom = lerpf(upper_mouth_outer_bottom, to.upper_mouth_outer_bottom, weight)
	result.upper_mouth_outer_top = lerpf(upper_mouth_outer_top, to.upper_mouth_outer_top, weight)
	result.variance = lerpf(variance, to.variance, weight)
	result.variance_spike = lerpf(variance_spike, to.variance_spike, weight)
	result.variance_spike_duration_min = roundf(lerpf(variance_spike_duration_min, to.variance_spike_duration_min, weight))
	result.variance_spike_duration_max = roundf(lerpf(variance_spike_duration_max, to.variance_spike_duration_max, weight))
	result.variance_spike_delay_min = lerpf(variance_spike_delay_min, to.variance_spike_delay_min, weight)
	result.variance_spike_delay_max = lerpf(variance_spike_delay_max, to.variance_spike_delay_max, weight)
	return result
