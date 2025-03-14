shader_type canvas_item;

#include "res://shaders/util.gdshaderinc"

global uniform sampler2D value_noise_texture : repeat_enable, filter_linear;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float jitter_amount = 0.0;

void fragment() {
	vec4 value_noise = texture(value_noise_texture, UV) * 2.0 - 1.0;
	vec4 color = textureLod(screen_texture, UV + (jitter_amount + 0.5) * value_noise.xy * SCREEN_PIXEL_SIZE, 0.0);
	COLOR = color;
}
