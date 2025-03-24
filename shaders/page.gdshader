shader_type spatial;

render_mode cull_disabled, diffuse_lambert, specular_disabled;//, vertex_lighting;

#include "util.gdshaderinc"
#include "volumetric_fog.gdshaderinc"

global uniform float texel_density;
global uniform sampler2D value_noise_texture : filter_nearest;
global uniform float value_noise_texture_size;

uniform sampler2D page_base_texture : hint_default_white, filter_nearest, source_color, repeat_enable;
uniform sampler2D page_illustration_texture : hint_default_white, filter_nearest, source_color, repeat_enable;
uniform sampler2D page_text_texture : hint_default_white, filter_nearest, source_color, repeat_enable;
uniform sampler2D page_number_texture : hint_default_white, filter_nearest, source_color, repeat_enable;
instance uniform int page = 1;
uniform float noise = 0.1;

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
	vec4 page_base = texture(page_base_texture, UV * vec2(0.25, 1.0) + vec2(mod(float(page - 1), 4.0) * 0.25, 0.0));
	vec4 page_illustration = texture(page_illustration_texture, UV * vec2(0.1, 1.0) + vec2(floor(float(page) / 15.0) * 0.1, 0.0));
	vec4 page_text = texture(page_text_texture, UV * vec2(0.1, 1.0) + vec2(mod(float(page - 1), 10.0) * 0.1, 0.0));
	vec4 page_number = texture(page_number_texture, UV * vec2(0.0625, 0.125) + vec2(mod(float(page - 1), 16.0) * 0.0625, floor(float(page - 1) * 0.0625) * 0.125));
	ALBEDO = page_base.rgb;
	ALBEDO = mix(ALBEDO, page_illustration.rgb, page_illustration.a);
	ALBEDO = mix(ALBEDO, page_text.rgb, page_text.a);
	ALBEDO = mix(ALBEDO, page_number.rgb, page_number.a);
	ALBEDO *= remap(value_random.x, 0.0, 1.0, 1.0 - noise, 1.0);
	EMISSION = mix(vec3(0.0), page_illustration.rgb, page_illustration.a * 0.5);
	ALPHA = page_base.a;
	
	//LIGHT_VERTEX = (VIEW_MATRIX * vec4(floor(world_pos * texel_density + 0.001) * inv_texel_density, 1.0)).xyz;
	FOG = volumetric_fog(world_pos, CAMERA_POSITION_WORLD);
	EMISSION *= 1.0 - FOG.a;
}
