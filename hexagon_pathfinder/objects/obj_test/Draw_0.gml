/// @description 여기에 설명 삽입
// 이 에디터에 코드를 작성할 수 있습니다
/*
shader_set(shd_test2);
draw_sprite(spr_hexagon,0,mouse_x,mouse_y);
shader_reset();

shader_set(shd_test3);
draw_sprite(spr_hexagon,0,mouse_x,mouse_y+300);
shader_reset();

*/
shader_set(shd_test);
draw_surface_ext(global.map._.map_pathfind_surf,mouse_x,mouse_y,4,4,0,c_white,1);
draw_rectangle(mouse_x+18*4,mouse_y-4,mouse_x+18*4+4,mouse_y,false);
shader_reset();