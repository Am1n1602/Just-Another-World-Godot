shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    tex_color.rgb = 1.0 - tex_color.rgb; // invert black ↔ white
    COLOR = tex_color;
}
