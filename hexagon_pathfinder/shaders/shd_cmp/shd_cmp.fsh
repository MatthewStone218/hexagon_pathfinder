//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_under_texture;

void main()
{
	vec4 base_color = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 under_color = texture2D( u_under_texture, v_vTexcoord );
    vec4 diff_color = vec4(abs( base_color.r - under_color.r ),abs( base_color.g - under_color.g ),abs( base_color.b - under_color.b ),abs( base_color.a - under_color.a ));
	if(max(max(diff_color.r,diff_color.g),max(diff_color.b,diff_color.a)) == 0.0){
		gl_FragColor = vec4(1.0,0.0,0.0,1.0);
	} else {
		gl_FragColor = vec4(0.0,0.0,0.0,1.0);
	}
}
