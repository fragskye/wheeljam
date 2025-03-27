#include "shared_global_uniforms.gdshaderinc"
#include "util.gdshaderinc"

global uniform vec4 grunge_highlight;
global uniform sampler2D grunge_noise_texture : filter_linear, repeat_enable;

vec3 grunge(vec3 albedo, vec3 world_pos, vec4 value_random) {
	vec3 quantized_world_pos = floor(world_pos * texel_density + 0.01) * inv_texel_density;
	float grunge_noise = texture(grunge_noise_texture, quantized_world_pos.xz * 0.005).r * 4.0 - 2.0;
	if (quantized_world_pos.y + value_random.y < grunge_noise) {
		float grunge_noise_2 = texture(grunge_noise_texture, quantized_world_pos.xz * 0.005 + vec2(TIME * 0.01)).r;
		float amt = -(quantized_world_pos.y * 0.5 + value_random.y - grunge_noise) * 0.666;
		return mix(albedo * (1.0 - amt), grunge_highlight.rgb, remap_clamp(amt, 0.3, 1.0, 0.0, 1.0) * value_random.z * grunge_noise_2);// abs(world_normal.y) * 0.5 + 0.5;
		/*ALBEDO = vec3(1.0, 0.0, 0.0);
		if (amt > 0.3) {
			ALBEDO = vec3(0.0, 1.0, 0.0);
		}/**/
	}
	return albedo;
}
