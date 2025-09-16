//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
	vec4 base_color = texture2D( gm_BaseTexture, v_vTexcoord );
	
	bool aa = mod(floor(gl_FragCoord.x),8.0) > 4.0;
	
	if(aa){
		gl_FragColor = vec4(0.5,float(0),0.0,0.5);
		return;
	} else {
		gl_FragColor = vec4(0.5,float(0),1.0,1.0);
		return;
	}
	
	gl_FragColor = base_color;
}
