shader_type canvas_item;

uniform bool flash = false;
uniform vec4 override_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    if (flash) {
        COLOR = vec4(1.0, 1.0, 1.0, tex.a);
    } else {
        COLOR = vec4(tex.rgb * override_color.rgb, tex.a);
    }
}
