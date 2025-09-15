//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_underTexture;

void main()
{
    vec4 diffColor = abs(texture2D( gm_BaseTexture, v_vTexcoord ) - u_underTexture);
	if(max(max(diffColor.r,diffColor.g),max(diffColor.b,diffColor.a)) == 0){
		gl_FragColor = vec4(1.0,0.0,0.0,1.0);
	} else {
		gl_FragColor = vec4(0.0,0.0,0.0,1.0);
	}
}
