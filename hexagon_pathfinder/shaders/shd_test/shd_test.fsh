//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
	/*
		y: lt
		p: t
		mint: rt
		
		g: lb
		r: b
		b: rb
	*/
	
    vec4 baseColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	if(abs(baseColor.b - 90.0/255.0) < 0.001){
		gl_FragColor = vec4(1.0,0.0,0.0,1.0);
		return;
	}
	
	if(abs(baseColor.b - 70.0/255.0) < 0.001){
		gl_FragColor = vec4(0.0,1.0,0.0,1.0);
		return;
	}
	
	if(abs(baseColor.b - 110.0/255.0) < 0.001){
		gl_FragColor = vec4(0.0,0.0,1.0,1.0);
		return;
	}
	
	if(abs(baseColor.b - 10.0/255.0) < 0.001){
		gl_FragColor = vec4(1.0,1.0,0.0,1.0);
		return;
	}
	
	if(abs(baseColor.b - 30.0/255.0) < 0.001){
		gl_FragColor = vec4(1.0,0.0,1.0,1.0);
		return;
	}
	
	if(abs(baseColor.b - 50.0/255.0) < 0.001){
		gl_FragColor = vec4(0.0,1.0,1.0,1.0);
		return;
	}
	
	gl_FragColor = vec4(0.0,0.0,0.0,1.0);
}
