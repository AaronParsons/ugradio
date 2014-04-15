pro grid_event, ev

widget_control, ev.top, get_uvalue=base_id		;  Get base id from uvalue
widget_control, base_id, get_uvalue=params		;  Get parameter structure
widget_control, ev.id, get_uvalue=uval		;  Get uvalue from calling widget

case uval of
	'size':		params.size = ev.value
	'space':	params.space = float(ev.value) / 10.
	'system':	begin
		case ev.value of
;			'  Close Window  ':	widget_control, params.grid_id, /destroy
			'  Help  ':		create_help, params.base_id, ev.top
		endcase
		end
endcase

widget_control, params.base_id, set_uvalue=params	;  Update parameter structure

if (params.prog_id NE 0L) then begin	;  Check to see if the progress widget exists
	;  Update the scan progress widget as necessary.
	scan_progress, params.win_num, params.size, params.space
endif

end

