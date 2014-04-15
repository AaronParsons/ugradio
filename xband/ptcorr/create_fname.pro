pro create_fname, base_id

widget_control, base_id, get_uvalue=params

params.fname_id = widget_base(title='Change File Name', /column, group_leader=params.auto_id)
	r1c1 = widget_base(params.fname_id, /row, group_leader=params.fname_id)
		field0 = cw_bgroup(r1c1, params.fvalues[*,0], /column, /exclusive, $
			uvalue='field0', set_value=params.fields[0,1], label_top='Field 1')
		field1 = cw_bgroup(r1c1, params.fvalues[*,0], /column, /exclusive, $
			uvalue='field1', set_value=params.fields[1,1], label_top='Field 2')
		field2 = cw_bgroup(r1c1, params.fvalues[*,0], /column, /exclusive, $
			uvalue='field2', set_value=params.fields[2,1], label_top='Field 3')
		field2 = cw_bgroup(r1c1, params.suffix, /column, /exclusive, $
			uvalue='suffix', set_value=params.fields[3,1], label_top='Suffix')
	r2c1 = widget_base(params.fname_id, /row, group_leader=params.fname_id)
		junk = widget_label(r2c1, value='Example File Name:  ')
		text = widget_text(r2c1, value=params.examp)
	r1c2 = widget_base(params.fname_id, /row, group_leader=params.fname_id, /align_center)
		junk = widget_button(r1c2, value=' Update Format ', uvalue='update')
		junk = widget_button(r1c2, value=' Make No Changes ', uvalue='cancel')
		junk = widget_button(r1c2, value=' Help ', uvalue='help')

widget_control, base_id, set_uvalue=params
widget_control, params.fname_id, /realize
widget_control, params.fname_id, set_uvalue={	params:		params, $
						text_wid:	text}
xmanager, 'fname', params.fname_id, /no_block


end
