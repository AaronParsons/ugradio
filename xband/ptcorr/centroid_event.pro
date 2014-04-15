pro centroid_event, ev

widget_control, ev.top, get_uvalue=base_id ;  Get base id from uvalue
widget_control, base_id, get_uvalue=params ;  Get parameter structure
widget_control, ev.id, get_uvalue=uval ;  Get uvalue from calling widget

case strtrim(uval, 2) of
    'coords':	begin
        case 1 of
            (strtrim(ev.value, 2) EQ 'Positively' AND ev.select):  params.pow_dir = 0
            (strtrim(ev.value, 2) EQ 'Negatively' AND ev.select):  params.pow_dir = 1
            else:
        endcase
    end
    'coords':	begin
        case 1 of
            (strtrim(ev.value, 2) EQ 'Sky' AND ev.select):	params.coords_flag = 0
            (strtrim(ev.value, 2) EQ 'Encoder' AND ev.select):  params.coords_flag = 1
            else:
        endcase
    end
    'corrlog':  begin
        widget_control, ev.id, get_value=temp
        params.corr_log = temp[0]
    end
    'system':   begin
        case strtrim(ev.value, 2) of
            'Help':	create_help2, params.base_id, ev.top
        end
    endcase
endcase

widget_control, base_id, set_uvalue=params ;  Update parameter structure

end




































