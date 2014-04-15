pro input_event, ev

widget_control, ev.top, get_uvalue=base_id		;  Get base id from uvalue
widget_control, base_id, get_uvalue=params		;  Get parameter structure
widget_control, ev.id, get_uvalue=uval		;  Get uvalue from calling widget

case strtrim(uval, 2) of
	'i_forfname':	begin
		widget_control, ev.id, get_value=temp
		params.i_forfname = temp[0]
		end
	'i_revfname':	begin
		widget_control, ev.id, get_value=temp
		params.i_revfname = temp[0]
		end
	'auto_anal':	begin
		if (ev.select AND ev.value EQ 'On') then $
			params.auto_anal = 1 $
		else $
			params.auto_anal = 0
		end
	'system':	begin
		case strtrim(ev.value, 2) of
			'Help':	create_help, params.base_id, ev.top
		endcase
		end
endcase

widget_control, params.base_id, set_uvalue=params	;  Update parameter structure

end

