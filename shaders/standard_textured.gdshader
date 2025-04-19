shader_type spatial;

render_mode cull_disabled, diffuse_lambert, specular_disabled;//, vertex_lighting;

#include "shared_global_uniforms.gdshaderinc"
#include "util.gdshaderinc"
#include "volumetric_fog.gdshaderinc"
#include "grunge.gdshaderinc"

uniform sampler2D albedo_texture : hint_default_white, filter_nearest, source_color, repeat_enable;
uniform bool emissive = false;
uniform float emissive_intensity = 1.0;
uniform float noise_intensity = 0.1;

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
	float inv_value_noise_texture_size = 1.0 / value_noise_texture_size;

	vec3 abs_local_normal = abs(local_normal);
	float max_xz = max(abs_local_normal.x, abs_local_normal.z);
	float max_yz = max(abs_local_normal.y, abs_local_normal.z);
	vec2 local_planar_uv = abs_local_normal.y >= max_xz ? local_pos.xz : abs_local_normal.x >= max_yz ? local_pos.zy : local_pos.xy;
	vec4 value_random = texture(value_noise_texture, local_planar_uv * inv_value_noise_texture_size * texel_density);
	vec4 albedo = texture(albedo_texture, UV);
	ALBEDO = albedo.rgb;
	ALBEDO *= remap(value_random.x, 0.0, 1.0, 1.0 - noise_intensity, 1.0);
	if (albedo.a < 0.5) {
		discard;
	}

	ALBEDO = grunge(ALBEDO, world_pos, value_random);

	if (emissive) {
		EMISSION = emissive_intensity * ALBEDO;
	}

	//LIGHT_VERTEX = (VIEW_MATRIX * vec4(floor(world_pos * texel_density + 0.001) * inv_texel_density, 1.0)).xyz;
	FOG = volumetric_fog(world_pos, CAMERA_POSITION_WORLD);
	EMISSION *= 1.0 - FOG.a;
}
