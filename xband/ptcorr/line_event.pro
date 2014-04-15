pro line_event, ev

widget_control, ev.top, get_uvalue=base_id ;  Get base id from uvalue
widget_control, base_id, get_uvalue=params ;  Get parameter structure
widget_control, ev.id, get_uvalue=uval ;  Get uvalue from calling widget

case strtrim(uval, 2) of
    'remove':	begin
        case 1 of
            (strtrim(ev.value, 2) EQ 'Yes' AND ev.select):	begin
                for count = 1, 3 do widget_control, params.line_rows[count], /sensitive
                params.remove_flag = 1
            end
            (strtrim(ev.value, 2) EQ 'No' AND ev.select):	begin
                for count = 1, 3 do widget_control, params.line_rows[count], sensitive=0
                params.remove_flag = 0
            end
            else:
        endcase
    end
    'order':    if ev.select then params.order = fix(ev.value)
    'l_min':	params.l_min = ev.index + 1
    'l_max':	params.l_max = ev.index + 1
    'r_min':	params.r_min = ev.index + 1
    'r_max':	params.r_max = ev.index + 1
    'system':   begin
        case strtrim(ev.value, 2) of
            'Help':	create_help2, params.base_id, ev.top
        end
    endcase
endcase

widget_control, base_id, set_uvalue=params ;  Update parameter structure

end




































