pro create_auto, base_id

widget_control, base_id, get_uvalue=params

params.auto_id = widget_base(/column, group_leader=base_id, $
		title='Automatic Scan Parameters')
	r1 = widget_base(params.auto_id, /row, group_leader=params.auto_id)
		junk = widget_label(r1, value='Auto Filename:  ', xsize=140)
		params.auto_fname = widget_text(r1, xsize=12, value=params.examp)
		junk = widget_button(r1, value='Change', uvalue='change')
	r2 = widget_base(params.auto_id, /row, group_leader=params.auto_id)
		junk = widget_label(r2, value='File Path:  ', xsize=140)
		junk = widget_text(r2, xsize=20, value=params.a_fpath, $
			uvalue='path', /editable, /all_events)
	r3 = widget_base(params.auto_id, /row, group_leader=params.auto_id)
		junk = widget_label(r3, value='File Number:  ', xsize=140)
		params.auto_fnum = widget_text(r3, xsize=20, value=strtrim(params.fnum, 2), $
			uvalue='initial', /editable, /all_events)
	r4 = widget_base(params.auto_id, /row, group_leader=params.auto_id)
		junk = widget_label(r4, value='Inter-Scan Delay (s):  ', xsize=140)
		junk = widget_text(r4, xsize=20, value=strtrim(params.delay, 2), $
			uvalue='delay', /editable, /all_events)
	r5 = widget_base(params.auto_id, /row, group_leader=params.auto_id)
		junk = widget_label(r5, value='Pointing Mode:  ', xsize=140)
		junk = cw_bgroup(r5, ['Fwd','Rev', 'Auto'], column=3, $
			/exclusive, set_value=params.a_mode, uvalue='a_mode')
	r6 = widget_base(params.auto_id, /row, group_leader=params.auto_id)
		junk = widget_label(r6, value='Pointing Corrections:', xsize=140)
		junk = cw_bgroup(r6, ['All','None','Dial'], column=3, $
			/exclusive, set_value=params.a_correct, uvalue='a_correct')
	r7 = widget_base(params.auto_id, /row, group_leader=params.auto_id)
		junk = widget_label(r7, value='Object:  ', xsize=140)
		junk = cw_bgroup(r7, ['Sun','Moon', 'Auto'], column=3, $
			/exclusive, set_value=params.a_source, uvalue='a_source')
	r8 = widget_base(params.auto_id, /row, group_leader=params.auto_id)
		junk = widget_label(r8, value='Auto Analyze?', xsize=140)
		junk = cw_bgroup(r8, ['Yes', 'No', 'Re-Run'], column=3, /exclusive, $
			uvalue='autoanal', set_value=1, /return_name)  ;TO MAKE AUTO ANALYSIS THE DEFAULT, CHANGE SET_VALUE TO 0 IN THE ABOVE LINE
	r9 = widget_base(params.auto_id, /row, group_leader=params.auto_id, /align_center)
		junk = cw_bgroup(r9, [' Start Scanning ', ' Stop Scanning ', ' Help '], $
			/row, uvalue='system', /return_name)



params.auto_rows_id = [r1, r2, r3, r4, r5, r6, r7, r8]
widget_control, base_id, set_uvalue=params
widget_control, params.auto_id, set_uvalue=base_id
widget_control, params.auto_id, /realize
xmanager, 'auto', params.auto_id, /no_block
end

