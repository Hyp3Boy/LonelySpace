shader_type spatial;

// CAMBIADO: de cull_back a cull_disabled para que se dibuje por ambos lados
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_lambert, specular_schlick_ggx;

uniform vec4 water_color : source_color = vec4(0.1, 0.4, 0.6, 0.7);
uniform vec4 underwater_color : source_color = vec4(0.05, 0.25, 0.4, 0.92); // Un color más opaco para cuando estás debajo
uniform sampler2D noise_texture;
uniform float wave_speed = 0.05;
uniform float wave_strength = 0.08;
uniform vec2 wave_direction = vec2(1.0, 0.5);

void vertex() {
	// Mueve los vértices para crear olas (sin cambios)
	vec2 uv_offset = UV + (TIME * wave_speed * normalize(wave_direction));
	float noise = texture(noise_texture, uv_offset).r;
	VERTEX.y += (noise - 0.5) * 2.0 * wave_strength;
}

void fragment() {
	// NUEVA LÓGICA: Detectamos si miramos desde arriba o desde abajo
	// dot(NORMAL, VIEW) es positivo si miramos la cara frontal (desde arriba)
	// y negativo si miramos la cara trasera (desde abajo).
	if (dot(NORMAL, VIEW) > 0.0) {
		// --- LÓGICA ORIGINAL (VISTA DESDE ARRIBA) ---
		ALBEDO = water_color.rgb;
		ALPHA = water_color.a;

		// Efecto Fresnel: más opaco en los bordes
		float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
		ALPHA = ALPHA + fresnel * (1.0 - ALPHA);

	} else {
		// --- LÓGICA NUEVA (VISTA DESDE ABAJO) ---
		// Hacemos que el agua se vea mucho más opaca y densa
		ALBEDO = underwater_color.rgb;
		ALPHA = underwater_color.a;
	}
}