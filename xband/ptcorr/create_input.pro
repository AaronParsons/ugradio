pro create_input, base_id

widget_control, base_id, get_uvalue=params	;  Get parameter structure

params.input_id = widget_base(/column, group_leader=base_id, title='Analysis File Input', $
	uvalue=base_id)
	r0 = widget_base(params.input_id, /row, group_leader=params.input_id)
		junk = widget_label(r0, value='Forward Filename:  ', xsize=140)
		params.i_fname = widget_text(r0, xsize=20, value=params.m_fpath + params.m_fname, $
			uvalue='i_forfname', /editable, /all_events)
	r1 = widget_base(params.input_id, /row, group_leader=params.input_id)
		junk = widget_label(r1, value='Reverse Filename:  ', xsize=140)
		junk = widget_text(r1, xsize=20, value='', $
			uvalue='i_revfname', /editable, /all_events)
	r2 = widget_base(params.input_id, /row, group_leader=params.input_id)
		junk = widget_label(r2, value='Auto Analysis:  ', xsize=140)
		junk = cw_bgroup(r2, ['On', 'Off'], column=2, /exclusive, $
			set_value=0, uvalue='auto_anal', /return_name)
	r3 = widget_base(params.input_id, /row, group_leader=params.input_id, /align_center)
		junk = cw_bgroup(r3, ['  Help  '], /row, uvalue='system', /return_name)

widget_control, base_id, set_uvalue=params		;  Update parameter structure
widget_control, params.input_id, /realize		;  Realize widget
xmanager, 'input', params.input_id, /no_block		;  Register widget

end
