pro create_manual, base_id

widget_control, base_id, get_uvalue=params	;  Get parameter structure

params.manual_id = widget_base(/column, group_leader=base_id, $
		title='Manual Scan Parameters', uvalue=params.base_id)
	r0 = widget_base(params.manual_id, /row, group_leader=params.manual_id)
		junk = widget_label(r0, value='Filename:  ', xsize=140)
		junk = widget_text(r0, xsize=20, value=params.m_fname, $
			uvalue='m_fname', /editable, /all_events)
	r1 = widget_base(params.manual_id, /row, group_leader=params.manual_id)
		junk = widget_label(r1, value='File Path:  ', xsize=140)
		junk = widget_text(r1, xsize=20, value=params.m_fpath, $
			uvalue='m_path', /editable, /all_events)		
	r2 = widget_base(params.manual_id, /row, group_leader=params.manual_id)
		junk = widget_label(r2, value='Pointing Mode:  ', xsize=140)
		junk = cw_bgroup(r2, ['Fwd','Rev'], column=2, $
			/exclusive, set_value=params.m_mode, uvalue='m_mode')
	r3 = widget_base(params.manual_id, /row, group_leader=params.manual_id)
		junk = widget_label(r3, value='Pointing Corrections:', xsize=140)
		junk = cw_bgroup(r3, ['All', 'None', 'Dial'], column=3, $
			/exclusive, set_value=params.m_correct, uvalue='m_correct')
	r4 = widget_base(params.manual_id, /row, group_leader=params.manual_id)
		junk = widget_label(r4, value='Object:  ', xsize=140)
		junk = cw_bgroup(r4, ['Sun','Moon'], column=2, $
			/exclusive, set_value=params.m_source, uvalue='m_source')
	r5 = widget_base(params.manual_id, /row, group_leader=params.manual_id, $
		/align_center)
		junk = cw_bgroup(r5, ['  Scan It!  ', '  Help  '], $
			/row, uvalue='system', /return_name)

widget_control, base_id, set_uvalue=params		;  Update parameter structure
widget_control, params.manual_id, /realize		;  Realize widget
xmanager, 'manual', params.manual_id, /no_block		;  Register widget

end

