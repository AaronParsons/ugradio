pro create_data, base_id

draw_win = make_array(4, /long)

widget_control, base_id, get_uvalue=params	;  Get parameter structure from top widget
;  Make the widget
params.data_id = widget_base(/column, group_leader=base_id, title='Data and Fits', $
	uvalue=params.base_id)
	r1 = widget_base(params.data_id, /row, group_leader=params.data_id)
		junk = widget_label(r1, value=' ', xsize=50)
		junk = widget_label(r1, value='East', xsize=200)
		junk = widget_label(r1, value='West', xsize=200)
	r2 = widget_base(params.data_id, /row, group_leader=params.data_id)
		junk = widget_label(r2, value='Raw Data', xsize=50)
		draw_win[0] = widget_draw(r2, xsize=200, ysize=250)
		draw_win[1] = widget_draw(r2, xsize=200, ysize=250)
	r3 = widget_base(params.data_id, /row, group_leader=params.data_id)
		junk = widget_label(r3, value='Fit Data', xsize=50)
		draw_win[2] = widget_draw(r3, xsize=200, ysize=250)
		draw_win[3] = widget_draw(r3, xsize=200, ysize=250)
	r4 = widget_base(params.data_id, /row, group_leader=params.data_id, /align_center)
		junk = cw_bgroup(r4, ['  Help  '], $
			/row, uvalue='system', /return_name)

widget_control, params.data_id, /realize	;  Realize the widget

for count = 0, 3 do begin
	widget_control, draw_win[count], get_value=win_num
	params.data_win[count] = win_num
endfor

widget_control, params.base_id, set_uvalue=params	;  Update parameter structure
xmanager, 'data', params.data_id, /no_block	;  Register the widget and set no block

end
