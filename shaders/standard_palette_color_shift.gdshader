shader_type spatial;

render_mode cull_back, diffuse_lambert, specular_disabled, vertex_lighting;

#include "util.gdshaderinc"

global uniform float texel_density;
global uniform sampler2D value_noise_texture : filter_nearest;
global uniform float value_noise_texture_size;

uniform sampler2D palette : hint_default_white, filter_nearest, source_color, repeat_disable;
uniform bool emissive = false;

instance uniform float hue_shift = 0.0;
instance uniform float saturation_scalar = 1.0;
instance uniform float value_scalar = 1.0;

varying vec3 local_pos;
varying vec3 local_normal;

void vertex() {
	local_pos = VERTEX;
	local_normal = NORMAL;
}

void fragment() {
	float inv_texel_density = 1.0 / texel_density;
	float inv_value_noise_texture_size = 1.0 / value_noise_texture_size;

	vec3 abs_local_normal = abs(local_normal);
	float max_xz = max(abs_local_normal.x, abs_local_normal.z);
	float max_yz = max(abs_local_normal.y, abs_local_normal.z);
	vec2 local_planar_uv = abs_local_normal.y >= max_xz ? local_pos.xz : abs_local_normal.x >= max_yz ? local_pos.zy : local_pos.xy;
	vec4 value_random = texture(value_noise_texture, local_planar_uv * inv_value_noise_texture_size * texel_density);
	ALBEDO = texture(palette, UV + vec2(0.0, 0.00005 + value_random.x * 0.1249)).rgb;
	ALBEDO = hsv_to_rgb(rgb_to_hsv(ALBEDO) * vec3(1.0, saturation_scalar, value_scalar) + vec3(hue_shift, 0.0, 0.0));
	if (emissive) {
		EMISSION = ALBEDO;
	}
}
