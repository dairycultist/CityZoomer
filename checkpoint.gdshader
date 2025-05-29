shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = vec3(1, 1, 0);
	ALPHA = clamp(UV.y + sin(TIME + UV.x * PI * 4.0) * 0.1 - 0.1, 0, 1);
}
