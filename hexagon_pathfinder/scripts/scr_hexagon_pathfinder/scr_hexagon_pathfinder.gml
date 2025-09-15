// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
function hexagon_map(w,h,h_repeat,v_repeat){
	return new __class_hexagon_map__(w,h,h_repeat,v_repeat);
}

function __class_hexagon_map__(w,h,h_repeat,v_repeat) constructor {
	width = w;
	height = h;
	horizon_repeat = h_repeat;
	vertical_repeat = v_repeat;
	
	if(horizon_repeat && ((width mod 2) == 1)){
		show_error("Width of map must be even when it horizontal repeated!");
	}
	
	map = [];
	
	for(var i = 0; i < width; i++){
		for(var ii = 0; ii < height+1; ii++){
			map[i][ii] = -1;
		}
	}
	
	get_map_surf_x = function(xx){
		return xx;
	};
	get_map_surf_y = function(xx,yy){
		return yy*2 + ((xx mod 2) == 1);
	};
	set_value = function(xx,yy,val){
		map[xx][yy*2 + ((xx mod 2) == 1)] = val;
		map[xx][yy*2 + ((xx mod 2) == 1) + 1] = val;
	};
}
