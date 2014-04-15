function analysis, ref, ref2, scanner_id

params = {base_id:	0L, $		;  Base Widget ID
	  line_id:	0L, $		;  Baseline fitting widget ID
	  data_id:	0L, $		;  Display widget ID
          centroid_id:  0L, $
	  data_win:	[0L, 0L, 0L, 0L], $;  Window IDs
	  fnum_id:	0L, $		;  Text widget ID for file number
          line_rows:    [0L, 0L, 0L, 0L, 0L], $ ;  baseline row ID's
          cen_rows:     [0L, 0L, 0L, 0L], $ ;  Rows ID's for the centroid window
	  fnum:		'Run', $	;  File number being analyzed
	  l_min:	1, $		;  Min. Left points for baseline removal
	  l_max:	4, $		;  Max. Left points for baseline removal
	  r_min:	1, $		;  Min. Right points for baseline removal
	  r_max:	4, $		;  Max. Right points for baseline removal
	  order:	2, $		;  Polynomial order for baseline removal
	  idle_time:	2, $		;  Idle time between checking for scans
	  stop_flag:	0, $		;  Analyzer stop flag
          pow_dir:      1, $            ;  Direction of increasing power, 1=negative
          remove_flag:  1, $            ;  Baseline removal flag, 1=yes
          coords_flag:  1, $            ;  Coordinate system flag, 1=encoder
          view_flag:    1, $            ;  Which dataset to view in data window
          fnames:       ['', '', '', ''], $ ;  Data file names
          corr_log:     *ref2 + 'corr.log', $ ;  Correction logs path and name
	  fpath_ref:	ref2, $		;  Reference to file path
	  ref:		ref}		;  Pointer to heap variable containing file numbers

;  Create the tippy-top widget
base_id = widget_base(/column, title='PTCORR---Analyzer', group_leader=scanner_id)
	r1 = widget_base(base_id, /row, group_leader=base_id)
		junk = widget_label(r1, value='Analyzer Status:', xsize=154)
		params.fnum_id = widget_text(r1, xsize=20, value=(params.fnum))
	r2 = widget_base(base_id, /row, group_leader=base_id)
		junk = widget_label(r2, value='Data Display', xsize=154)
		junk = cw_bgroup(r2, ['Open', 'Close'], /row, uvalue='display', set_value=1, $
			/return_name, /exclusive)
	r3 = widget_base(base_id, /row, group_leader=base_id)
		junk = widget_label(r3, value='Baseline Fitting', xsize=154)
		junk = cw_bgroup(r3, ['Open', 'Close'], /row, uvalue='line', set_value=1, $
			/return_name, /exclusive)
	r4 = widget_base(base_id, /row, group_leader=base_id)
		junk = widget_label(r4, value='Centroid and Corrections', xsize=154)
		junk = cw_bgroup(r4, ['Open', 'Close'], /row, uvalue='cent', set_value=1, $
			/return_name, /exclusive)
	r5 = widget_base(base_id, /row, group_leader=base_id, /align_center)
		junk = cw_bgroup(r5, ['  Run  ', '  Stop  ', ' Clear Queue ', '  Help  '], /row, $
			uvalue='system', /return_name)



params.base_id = base_id
widget_control, base_id, set_uvalue=params
widget_control, base_id, /realize
widget_control, base_id, timer=1.0
xmanager, 'analysis', base_id, /no_block


return, base_id

end
