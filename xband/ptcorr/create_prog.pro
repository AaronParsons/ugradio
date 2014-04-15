pro create_prog, base_id

loadct, 39

widget_control, base_id, get_uvalue=params	;  Get parameter structure

params.prog_id = widget_base(/column, group_leader=base_id, title='Scan Grid/Progress', $
	uvalue=base_id)
	r1 = widget_base(params.prog_id, /row, group_leader=params.prog_id)
		draw_win = widget_draw(r1, xsize=296, ysize=270)
	r2 = widget_base(params.prog_id, /row, group_leader=params.prog_id, /align_center)
		junk = cw_bgroup(r2, ['  Help  '], /row, uvalue='system', /return_name)

widget_control, params.prog_id, /realize		;  Realize widget
widget_control, draw_win, get_value=win_num		;  Get draw window number
params.win_num = win_num				;  Stupid stuff
widget_control, base_id, set_uvalue=params		;  Update parameter structure
xmanager, 'prog', params.prog_id, /no_block		;  Register widget
scan_progress, params.win_num, params.size, params.space

end

