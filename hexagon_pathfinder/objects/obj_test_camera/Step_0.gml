/// @description 여기에 설명 삽입
// 이 에디터에 코드를 작성할 수 있습니다

if(mouse_check_button_pressed(mb_left)){
	mouse_x_prev = mouse_x;
	mouse_y_prev = mouse_y;
}
if(mouse_check_button(mb_left)){
	xx += mouse_x_prev-mouse_x;
	yy += mouse_y_prev-mouse_y;
}

if(mouse_wheel_down()){
	size_goal_power += 1;
}
if(mouse_wheel_up()){
	size_goal_power -= 1;
}

var _size_goal = power(size_goal_base,size_goal_power);
size += (_size_goal-size)/3;
camera_set_view_size(view_camera[0],base_width*size,base_heigt*size);
camera_set_view_pos(view_camera[0],
	xx - camera_get_view_width(view_camera[0])/2,
	yy - camera_get_view_height(view_camera[0])/2
);

mouse_x_prev = mouse_x;
mouse_y_prev = mouse_y;