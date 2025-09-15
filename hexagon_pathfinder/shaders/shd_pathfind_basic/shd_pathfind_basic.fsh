//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel;

void main()
{
    vec4 baseColor = texture2D( gm_BaseTexture, v_vTexcoord );
	
	
	gl_FragColor
}
