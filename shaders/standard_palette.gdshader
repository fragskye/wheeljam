shader_type spatial;

render_mode cull_back, diffuse_lambert, specular_disabled;//, vertex_lighting;

#include "util.gdshaderinc"
#include "volumetric_fog.gdshaderinc"

global uniform float texel_density;
global uniform sampler2D value_noise_texture : filter_nearest, repeat_enable;
global uniform float value_noise_texture_size;
global uniform vec4 grunge_highlight;
global uniform sampler2D grunge_noise_texture : filter_linear, repeat_enable;

uniform sampler2D palette : hint_default_white, filter_nearest, source_color, repeat_disable;
uniform bool emissive = false;
uniform float emissive_intensity = 1.0;

varying vec3 local_pos;
varying vec3 local_normal;
varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	local_pos = VERTEX;
	local_normal = NORMAL;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = (MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz;
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
	
	vec3 quantized_world_pos = floor(world_pos * texel_density + 0.01) * inv_texel_density;
	float grunge_noise = texture(grunge_noise_texture, quantized_world_pos.xz * 0.01).r * 3.0 - 1.5;
	if (quantized_world_pos.y + value_random.y < grunge_noise) {
		float grunge_noise_2 = texture(grunge_noise_texture, quantized_world_pos.xz * 0.01 + vec2(TIME * 0.01)).r;
		float amt = -(quantized_world_pos.y + value_random.y - grunge_noise) * 0.666;
		ALBEDO = mix(ALBEDO * (1.0 - amt), grunge_highlight.rgb, remap_clamp(amt, 0.3, 1.0, 0.0, 1.0) * value_random.z * grunge_noise_2);// abs(world_normal.y) * 0.5 + 0.5;
		/*ALBEDO = vec3(1.0, 0.0, 0.0);
		if (amt > 0.3) {
			ALBEDO = vec3(0.0, 1.0, 0.0);
		}/**/
	}
	
	if (emissive) {
		EMISSION = emissive_intensity * ALBEDO;
	}

	//LIGHT_VERTEX = (VIEW_MATRIX * vec4(floor(world_pos * texel_density + 0.001) * inv_texel_density, 1.0)).xyz;
	FOG = volumetric_fog(world_pos, CAMERA_POSITION_WORLD);
	EMISSION *= 1.0 - FOG.a;
}
