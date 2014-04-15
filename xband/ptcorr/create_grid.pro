pro create_grid, base_id

widget_control, base_id, get_uvalue=params	;  Get parameter structure from top widget
;  Make the widget
params.grid_id = widget_base(/column, group_leader=base_id, title='Gridding Parameters', $
	uvalue=params.base_id)
	r1 = widget_base(params.grid_id, /row, group_leader=params.grid_id)
		junk = widget_label(r1, value='Size:  ', xsize=140)
		junk = widget_slider(r1, value=params.size, minimum=3, maximum=60,$
			xsize=152, uvalue='size', /drag)
	r2 = widget_base(params.grid_id, /row, group_leader=params.grid_id)
		junk = widget_label(r2, value='Spacing (deg x 10):  ', xsize=140)
		junk = widget_slider(r2, value=params.space*10, minimum=1, maximum=20,$
			xsize=152, uvalue='space', /drag)
	r3 = widget_base(params.grid_id, /row, group_leader=params.grid_id, /align_center)
		junk = cw_bgroup(r3, ['  Help  '], $
			/row, uvalue='system', /return_name)

widget_control, params.grid_id, /realize	;  Realize the widget
xmanager, 'grid', params.grid_id, /no_block	;  Register the widget and set no block
widget_control, params.base_id, set_uvalue=params	;  Update parameter structure

end
