// NOTE: Shader automatically converted from Godot Engine 4.4.1.rc1's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, diffuse_lambert, specular_disabled;

#include "res://shaders/volumetric_fog.gdshaderinc"

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform int particles_anim_h_frames : hint_range(1, 128);
uniform int particles_anim_v_frames : hint_range(1, 128);
uniform bool particles_anim_loop;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;

	// Billboard Mode: Particles
	mat4 mat_world = mat4(
			normalize(INV_VIEW_MATRIX[0]),
			normalize(INV_VIEW_MATRIX[1]),
			normalize(INV_VIEW_MATRIX[2]),
			MODEL_MATRIX[3]);
	mat_world = mat_world * mat4(
			vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(0.0, 0.0, 1.0, 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;

	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);

	float h_frames = float(particles_anim_h_frames);
	float v_frames = float(particles_anim_v_frames);
	float particle_total_frames = float(particles_anim_h_frames * particles_anim_v_frames);
	float particle_frame = floor(INSTANCE_CUSTOM.z * float(particle_total_frames));
	if (!particles_anim_loop) {
		particle_frame = clamp(particle_frame, 0.0, particle_total_frames - 1.0);
	} else {
		particle_frame = mod(particle_frame, particle_total_frames);
	}
	UV /= vec2(h_frames, v_frames);
	UV += vec2(mod(particle_frame, h_frames) / h_frames, floor((particle_frame + 0.5) / h_frames) / v_frames);
	world_pos = (mat_world * vec4(VERTEX, 1.0)).xyz;
	world_normal = (mat_world * vec4(NORMAL, 0.0)).xyz;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);

	// Vertex Color Use as Albedo: Enabled
	albedo_tex *= COLOR;

	ALBEDO = albedo.rgb * albedo_tex.rgb;

	METALLIC = 0.0;
	SPECULAR = specular;
	ROUGHNESS = 1.0;
	ALPHA *= albedo.a * albedo_tex.a;
	
	FOG = simple_fog(world_pos, CAMERA_POSITION_WORLD);
	if (FOG.a < 0.4) {
		FOG.a = max(0.0, remap(FOG.a, 0.2, 0.4, 0.0, 0.4));
	}
}
