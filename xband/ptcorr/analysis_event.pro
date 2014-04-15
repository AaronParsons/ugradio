pro analysis_event, ev

widget_control, ev.top, get_uvalue=params ;  Get parameter structure
widget_control, ev.id, get_uvalue=uval ;  Get uvalue from calling widget

;  The timer keyword to the widget_control command allows the
;  this event to repeatedly check the ref heap variable to see
;  if there is any data to be analyzed.  The timer starts, and
;  thus the checking for data, when the widget is started.

if tag_names(ev, /structure_name) EQ 'WIDGET_TIMER' AND NOT(params.stop_flag) then begin
    if (*params.ref)[0] NE -1 then begin
        widget_control, params.fnum_id, set_value='File:  ' + strtrim((*params.ref)[0], 2)
                                ;  Desensitize the parameter window
                                ;  while analysis is proceeding.
        if params.line_id NE 0L then begin
            for count = 0, 3 do widget_control, params.line_rows[count], sensitive=0
        endif
        if params.centroid_id NE 0L then begin
            for count = 0, 2 do widget_control, params.cen_rows[count], sensitive=0
        endif
                                ;  find which data files have been
                                ;  created for the referenced file number
        names = findfile(*params.fpath_ref + '*' + strtrim((*params.ref)[0], 2) + '*' $
                         + '.sav', count=count)
        if count GT 1 then begin
                                ;  Check for sun forward file
            i = where(strpos(names, 'sun') NE -1 AND strpos(names, 'for') NE -1)
            if i[0] NE -1 then params.fnames[0] = names[i[0]] else params.fnames[0] = ''
                                ;  Check for sun reverse file
            i = where(strpos(names, 'sun') NE -1 AND strpos(names, 'rev') NE -1)
            if i[0] NE -1 then params.fnames[1] = names[i[0]] else params.fnames[1] = ''
                                ;  Check for moon forward file
            i = where(strpos(names, 'moon') NE -1 AND strpos(names, 'for') NE -1)
            if i[0] NE -1 then params.fnames[2] = names[i[0]] else params.fnames[2] = ''
                                ;  Check for moon reverse file
            i = where(strpos(names, 'moon') NE -1 AND strpos(names, 'rev') NE -1)
            if i[0] NE -1 then params.fnames[3] = names[i[0]] else params.fnames[3] = ''
        endif
        
        name_num = where(params.fnames NE '', count)
        
        for numcount = 0, count - 1 do $ ;  Do all the files that are found
          remove_n_fit, params, name_num[numcount], fit, head, dat
                                ;  Calculate errors and pointing corrections
        corr_consts, name_num, params
                                ;  Adjust the file numbers in the heap
                                ;  variable queue
        if n_elements(*params.ref) EQ 1 then begin
            *params.ref = -1 	;  No files left, set it -1
            idle_time = params.idle_time
        endif else begin
            *params.ref = (*params.ref)[1:*] ;  Remove first number
            idle_time = 0.1     ;  Cycle quickly if other files exist
        endelse
    endif else begin
        idle_time = params.idle_time
        widget_control, params.fnum_id, set_value='Run'
    endelse
    
    widget_control, ev.id, timer=idle_time ;  Reset the idle time
                                ;  Resensitize the baseline window
    if params.line_id NE 0L then begin
        for count = 0, 3 do widget_control, params.line_rows[count], /sensitive
    endif
    if params.centroid_id NE 0L then begin
        for count = 0, 2 do widget_control, params.cen_rows[count], /sensitive
    endif

    return
endif else if tag_names(ev, /structure_name) EQ 'WIDGET_TIMER' AND params.stop_flag then return



;  Take care of the button stuff
case strtrim(uval, 2) of
    'display':begin
        case 1 of
            (strtrim(ev.value, 2) EQ 'Open' AND ev.select):	begin
                create_data, params.base_id
                widget_control, params.base_id, get_uvalue=params
            end
            (strtrim(ev.value, 2) EQ 'Close' AND ev.select):begin
                widget_control, params.data_id, bad_id=trash, /destroy
                params.data_id = 0L
                widget_control, params.base_id, set_uvalue=params 
            end
            else:
        endcase
    end
    'line':	begin
        case 1 of
            (strtrim(ev.value, 2) EQ 'Open' AND ev.select):	begin
                create_line, params.base_id
                widget_control, params.base_id, get_uvalue=params
            end
            (strtrim(ev.value, 2) EQ 'Close' AND ev.select):begin
                widget_control, params.line_id, bad_id=trash, /destroy
                params.line_id = 0L
                widget_control, params.base_id, set_uvalue=params 
            end
            else:
        endcase
    end
    'cent':	begin
        case 1 of
            (strtrim(ev.value, 2) EQ 'Open' AND ev.select):	begin
                create_centroid, params.base_id
                widget_control, params.base_id, get_uvalue=params
            end
            (strtrim(ev.value, 2) EQ 'Close' AND ev.select):begin
                widget_control, params.centroid_id, bad_id=trash, /destroy
                params.centroid_id = 0L
                widget_control, params.base_id, set_uvalue=params 
            end
            else:
        endcase
    end
    'const':
    
    'system':	begin
        case strtrim(ev.value, 2) of
            'Run':	begin
                widget_control, params.fnum_id, set_value='Run'
                params.stop_flag = 0
                widget_control, ev.id, timer=0.1
            end
            'Stop':	begin
                params.stop_flag = 1
                widget_control, params.fnum_id, set_value='Stop'
            end
            'Clear Queue':begin
                widget_control, params.fnum_id, set_value='Queue Cleared'
                *params.ref = -1
            end
            'Help':     create_help2, params.base_id, ev.top
        endcase
    end
    else:
endcase




widget_control, params.base_id, set_uvalue=params 


end

