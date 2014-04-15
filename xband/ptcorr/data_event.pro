pro data_event, ev

widget_control, ev.top, get_uvalue=base_id ;  Get base id from uvalue
widget_control, base_id, get_uvalue=params ;  Get parameter structure
widget_control, ev.id, get_uvalue=uval ;  Get uvalue from calling widget

case strtrim(uval, 2) of
    'system':   begin
        case strtrim(ev.value, 2) of
            'Help':	create_help2, params.base_id, ev.top
        end
    endcase
endcase

widget_control, base_id, set_uvalue=params ;  Update parameter structure

end




































