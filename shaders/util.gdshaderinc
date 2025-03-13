#ifndef UTIL
#define UTIL

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

float remap01(float x, float a_min, float a_max) {
	return (x - a_min) / (a_max - a_min);
}

float remap(float x, float a_min, float a_max, float b_min, float b_max) {
	return (x - a_min) / (a_max - a_min) * (b_max - b_min) + b_min;
}

float remap01_clamp(float x, float a_min, float a_max) {
	return clamp((x - a_min) / (a_max - a_min), 0.0, 1.0);
}

float remap_clamp(float x, float a_min, float a_max, float b_min, float b_max) {
	return clamp((x - a_min) / (a_max - a_min), 0.0, 1.0) * (b_max - b_min) + b_min;
}

#endif
