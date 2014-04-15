pro create_centroid, base_id

widget_control, base_id, get_uvalue=params	;  Get parameter structure from top widget

params.centroid_id = widget_base(/column, group_leader=base_id, $
                                 title='Centroid and Corrections', uvalue=params.base_id)
r1 = widget_base(params.centroid_id, /row, group_leader=params.centroid_id)
   junk = widget_label(r1, value='Coordinate System', xsize=115)
   junk = cw_bgroup(r1, ['Sky', 'Encoder'], uvalue='coords', /return_name, $
                 /exclusive, set_value=params.coords_flag, /row, xsize=171)
r2 = widget_base(params.centroid_id, /row, group_leader=params.centroid_id)
   junk = widget_label(r2, value='Power Increases:', xsize=115)
   junk = cw_bgroup(r2, ['Positively', 'Negatively'], uvalue='coords',  $
                 /return_name, /exclusive, set_value=params.pow_dir, $
                 /row, xsize=171)
r3 = widget_base(params.centroid_id, /row, group_leader=params.centroid_id)
   junk = widget_label(r3, value='Corrections Log:', xsize=115)
   junk = widget_text(r3, xsize=20, value=params.corr_log, uvalue='corrlog', $
                      /editable, /all_events)
r4 = widget_base(params.centroid_id, /row, group_leader=params.centroid_id, /align_center)
   junk = cw_bgroup(r4, ['  Help  '], /row, uvalue='system', /return_name)

params.cen_rows=[r1, r2, r3, r4]
widget_control, params.centroid_id, /realize ;  Realize the widget
widget_control, params.base_id, set_uvalue=params ;  Update parameter structure
xmanager, 'centroid', params.centroid_id, /no_block ;  Register the widget and set no block

end
