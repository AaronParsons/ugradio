pro manual_event, ev

widget_control, ev.top, get_uvalue=base_id ;  Get base id from uvalue
widget_control, base_id, get_uvalue=params ;  Get parameter structure
widget_control, ev.id, get_uvalue=uval ;  Get uvalue from calling widget:

case uval of
    'm_fname':	begin
        widget_control, ev.id, get_value=temp
        params.m_fname = temp[0]
    end
    'm_mode':	if ev.select then params.m_mode = ev.value
    'm_correct':	if ev.select then params.m_correct = ev.value
    'm_source':	if ev.select then params.m_source = ev.value
    'm_path':		begin
        widget_control, ev.id, get_value=temp
        params.m_fpath=temp[0]
    end
    'system':	begin
        case strtrim(ev.value, 2) of
            'Scan It!':	begin
                if NOT(params.base_id EQ 0) then $
                  widget_control, params.base_id, sensitive=0
                if NOT(params.auto_id EQ 0) then $
                  widget_control, params.auto_id, sensitive=0
                if NOT(params.grid_id EQ 0) then $
                  widget_control, params.grid_id, sensitive=0
                if NOT(params.manual_id EQ 0) then $
                  widget_control, params.manual_id, sensitive=0
                if NOT(params.fname_id EQ 0) then $
                  widget_control, params.fname_id, sensitive=0
                
                scan, 	params.m_fpath + params.m_fname, $
                  size 	= params.size, $
                  space 	= params.space, $
                  reverse	= params.m_mode, $
                  nocorrect = params.m_correct, $
                  moon	= params.m_source, $
                  win_num	= params.win_num
                
                if NOT(params.base_id EQ 0) then $
                  widget_control, params.base_id, /sensitive
                if NOT(params.auto_id EQ 0) then $
                  widget_control, params.auto_id, /sensitive
                if NOT(params.grid_id EQ 0) then $
                  widget_control, params.grid_id, /sensitive
                if NOT(params.manual_id EQ 0) then $
                  widget_control, params.manual_id, /sensitive
                if NOT(params.fname_id EQ 0) then $
                  widget_control, params.fname_id, /sensitive
            end
            'Help':		create_help, params.base_id, ev.top
        endcase
    end
endcase

widget_control, params.base_id, set_uvalue=params ;  Update parameter structure

end


