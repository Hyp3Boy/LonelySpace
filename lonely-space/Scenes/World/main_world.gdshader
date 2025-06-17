shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

//=======================================================================//
//== PARÁMETROS AJUSTABLES DESDE EL INSPECTOR DE GODOT                  ==//
//=======================================================================//

group_uniforms rock_properties;
uniform sampler2D rock_albedo_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D rock_normal_texture : hint_normal, filter_linear_mipmap, repeat_enable;
uniform vec4 rock_tint : source_color = vec4(1.0);

group_uniforms dirt_properties;
uniform sampler2D dirt_albedo_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D dirt_normal_texture : hint_normal, filter_linear_mipmap, repeat_enable;
uniform vec4 dirt_tint : source_color = vec4(1.0);

group_uniforms terrain_settings;
uniform float texture_scale : hint_range(0.1, 20.0) = 5.0;
uniform float texture_offset_strength : hint_range(0.0, 1.0) = 0.5;
uniform float blend_power : hint_range(1.0, 10.0) = 4.0;
uniform float blend_sharpness : hint_range(1.0, 50.0) = 15.0;
uniform float steepness_threshold : hint_range(0.0, 1.0) = 0.45;

group_uniforms macro_variation;
uniform sampler2D macro_noise_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform float macro_noise_scale = 0.1;
uniform float macro_noise_influence : hint_range(0.0, 1.0) = 0.15;
uniform vec4 macro_color_a : source_color = vec4(1.0);
uniform vec4 macro_color_b : source_color = vec4(0.85, 0.85, 0.85, 1.0);

group_uniforms pbr_settings;
uniform float roughness : hint_range(0.0, 1.0) = 0.8;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

vec3 triplanar_sample(sampler2D p_texture, vec3 p_weights, vec3 p_position) {
    vec3 sample_x = texture(p_texture, p_position.zy).rgb;
    vec3 sample_y = texture(p_texture, p_position.xz + texture_offset_strength).rgb;
    vec3 sample_z = texture(p_texture, p_position.xy - texture_offset_strength).rgb;
    return sample_x * p_weights.x + sample_y * p_weights.y + sample_z * p_weights.z;
}

vec3 process_normal_map(vec3 normal_from_texture) {
	if (normal_from_texture == vec3(0.0)) {
		return vec3(0.5, 0.5, 1.0);
	}
	return normal_from_texture;
}

void fragment() {
    // 1. CALCULAR LA NORMAL GEOMÉTRICA REAL PARA LA LÓGICA DE MEZCLA
    // Esto representa la inclinación real de la cara del triángulo en este píxel.
    vec3 geometric_normal = -normalize(cross(dFdx(world_position), dFdy(world_position)));

    // 2. CALCULAR PESOS DE PROYECCIÓN PARA EL TRIPLANAR
    // Usamos la NORMAL de la malla (suave) para que las texturas se mezclen bien.
    vec3 blend_weights = abs(NORMAL);
    blend_weights = pow(blend_weights, vec3(blend_power));
    blend_weights = blend_weights / (blend_weights.x + blend_weights.y + blend_weights.z);

    // 3. MUESTREAR LAS TEXTURAS (sin cambios)
    vec3 rock_albedo = triplanar_sample(rock_albedo_texture, blend_weights, world_position * texture_scale);
    vec3 rock_normal = process_normal_map(triplanar_sample(rock_normal_texture, blend_weights, world_position * texture_scale));

    vec3 dirt_albedo = triplanar_sample(dirt_albedo_texture, blend_weights, world_position * texture_scale);
    vec3 dirt_normal = process_normal_map(triplanar_sample(dirt_normal_texture, blend_weights, world_position * texture_scale));

    // 4. CALCULAR LA MÁSCARA DE MEZCLA POR PENDIENTE (¡USANDO LA NORMAL GEOMÉTRICA!)
    // Comparamos la inclinación real de la superficie con el vector "arriba".
    float steepness = 1.0 - dot(geometric_normal, vec3(0.0, 1.0, 0.0));
    float blend_mask = smoothstep(
        steepness_threshold - (1.0 / blend_sharpness),
        steepness_threshold + (1.0 / blend_sharpness),
        steepness
    );

    // 5. MEZCLAR Y APLICAR LAS PROPIEDADES FINALES (sin cambios)
    ALBEDO = mix(dirt_albedo, rock_albedo, blend_mask);
    ALBEDO *= mix(dirt_tint.rgb, rock_tint.rgb, blend_mask);

    NORMAL_MAP = mix(dirt_normal, rock_normal, blend_mask);

    METALLIC = metallic;
    ROUGHNESS = roughness;

    // 6. VARIACIÓN MACRO (sin cambios)
    if (texture(macro_noise_texture, vec2(0.0)).a > 0.0) {
        vec3 macro_noise_value = triplanar_sample(macro_noise_texture, blend_weights, world_position * macro_noise_scale);
        vec3 macro_tint = mix(macro_color_b.rgb, macro_color_a.rgb, macro_noise_value.r);
        ALBEDO *= mix(vec3(1.0), macro_tint, macro_noise_influence);
    }
}