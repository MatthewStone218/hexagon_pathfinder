// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
function create_hexagon_map(w,h,h_repeat,v_repeat){
	return new __class_hexagon_map__(w,h,h_repeat,v_repeat);
}

function __class_hexagon_map__(w,h,h_repeat,v_repeat) constructor {
	width = w;
	height = h;
	horizon_repeat = h_repeat;
	vertical_repeat = v_repeat;
	
	map = [];
	for(var i = 0; i < width; i++){
		for(var ii = 0; ii < height; ii++){
			map[i][ii*2 + ((i mod 2) == 1)] = TILE_TYPE.TEST_1_COST;
			map[i][ii*2 + ((i mod 2) == 1) + 1] = TILE_TYPE.TEST_1_COST;
		}
	}
}

enum TILE_TYPE {
	TEST_WALL,
	TEST_1_COST,
	TEST_2_COST,
	TEST_3_COST
}