pro create_line, base_id

widget_control, base_id, get_uvalue=params	;  Get parameter structure from top widget

params.line_id = widget_base(/column, group_leader=base_id, $
	title='Baseline Fitting', uvalue=params.base_id)
	r1 = widget_base(params.line_id, /row, group_leader=params.line_id)
		junk = widget_label(r1, value='Remove Baseline?', xsize=154)
		junk = cw_bgroup(r1, ['No', 'Yes'], uvalue='remove', /return_name, $
			/exclusive, set_value=params.remove_flag, /row)
	r2 = widget_base(params.line_id, /row, group_leader=params.line_id)
		junk = widget_label(r2, value='Polynomial Order', xsize=154)
		junk = cw_bgroup(r2, ['0', '1', '2', '3'], /row, uvalue='order', $
			/return_name, /exclusive, set_value=params.order)
	r3 = widget_base(params.line_id, /row, group_leader=params.line_id, /align_center)
		values=strtrim(indgen(6) + 1, 2)
		junk = widget_label(r3, value='Left Fit Points:', xsize=120)
		junk = widget_droplist(r3, title='Min', value=values, uvalue='l_min')
		widget_control, junk, set_droplist_select=params.l_min - 1
		junk = widget_droplist(r3, title='Max', value=values, uvalue='l_max')
		widget_control, junk, set_droplist_select=params.l_max - 1
	r4 = widget_base(params.line_id, /row, group_leader=params.line_id, /align_center)
		junk = widget_label(r4, value='Right Fit Points:', xsize=120)
		junk = widget_droplist(r4, title='Min', value=values, uvalue='r_min')
		widget_control, junk, set_droplist_select=params.r_min - 1
		junk = widget_droplist(r4, title='Max', value=values, uvalue='r_max')
		widget_control, junk, set_droplist_select=params.r_max - 1
	r5 = widget_base(params.line_id, /row, group_leader=params.line_id, /align_center)
		junk = cw_bgroup(r5, ['  Help  '], /row, uvalue='system', /return_name)

params.line_rows = [r1, r2, r3, r4, r5]		;  Set row ID's
widget_control, params.line_id, /realize	;  Realize the widget
widget_control, params.base_id, set_uvalue=params	;  Update parameter structure
xmanager, 'line', params.line_id, /no_block	;  Register the widget and set no block

end
