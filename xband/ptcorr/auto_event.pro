pro auto_event, ev

widget_control, ev.top, get_uvalue=base_id ;  Get base id from uvalue
widget_control, base_id, get_uvalue=params ;  Get parameter structure
widget_control, ev.id, get_uvalue=uval ;  Get uvalue from calling widget

;print,'top of auto_Event' ; DEBUG

;  When a timer event arrives and the stop_flag is 0 then 
if (tag_names(ev, /structure_name) EQ 'WIDGET_TIMER' AND NOT(params.stop_flag)) then begin
                                ;  Do the scans
;print,'first ae loop' ;DEBUG

    if params.prog_id NE 0L then $
;print,'just before doing a scan';DEBUG
      scan_progress, params.win_num, params.size, params.space
    repeat_scanner, params, increment
                                ;  Check the event handler to see if anything has come
                                ;  down the pipe.
    result = widget_event(/nowait)		
                                ;  Get parameter structure
    widget_control, params.base_id, get_uvalue=params
                                ;  Check to see if auto analysis is on and update
                                ;  the heap variable (array) to include latest scan.
    if params.auto_anal AND increment AND params.a_mode EQ 2 then begin
        if (*params.ref)[0] EQ -1 then $
          *params.ref = params.fnum $
        else $
          *params.ref = [*params.ref, params.fnum]
    endif
                                ;  Increment the file number
    params.fnum = params.fnum + increment
                                ;  Insert the file number into the auto scanner widget
    widget_control, params.auto_fnum, set_value=strtrim(params.fnum, 2)
    widget_control, params.base_id, set_uvalue=params ;  Update parameter structure
                                ;  Set the timer
    print, 'Delaying...'
    widget_control, ev.id, timer=params.delay
    return
endif else $
  if (tag_names(ev, /structure_name) EQ 'WIDGET_TIMER' AND params.stop_flag) then return

;  The timer event is take care of, now do the button stuff.
case uval of
    'a_mode':	if ev.select then params.a_mode = ev.value
    'a_correct':	if ev.select then params.a_correct = ev.value
    'a_source':	if ev.select then params.a_source = ev.value
    'change':begin
        create_fname, params.base_id
        widget_control, base_id, get_uvalue=params ;  Get parameter structure
    end
    'initial':begin
        widget_control, ev.id, get_value=temp
        params.fnum = long(temp[0])
    end
    'delay':begin
        widget_control, ev.id, get_value=temp
        params.delay = long(temp[0])
    end
    'path':	begin
        widget_control, ev.id, get_value=temp
        params.a_fpath = temp[0]
        *params.fpath_ref = temp[0]
    end
    'autoanal':begin
        case 1 of
            (strtrim(ev.value, 2) EQ 'Yes' AND ev.select):	begin
                if (params.anal_id EQ 0L) then begin
                    params.anal_id = analysis(params.ref, params.fpath_ref, params.base_id)
                    params.auto_anal = 1
                endif
                params.test = 0
            end
            (strtrim(ev.value, 2) EQ 'No' AND ev.select):	begin
                *params.ref = -1
                params.auto_anal = 0
                widget_control, params.anal_id, bad_id=trash, /destroy
                params.anal_id = 0L
                params.test = 0
            end
            (strtrim(ev.value, 2) EQ 'Re-Run' AND ev.select):	begin
                if (params.anal_id EQ 0L) then begin
                    params.anal_id = analysis(params.ref, params.fpath_ref, params.base_id)
                    params.auto_anal = 1
                endif
                params.test = 1
            end
            else:
        endcase
    end
    'system':begin
        case strtrim(ev.value, 2) of
            'Start Scanning':	begin
                                ;  Desensitize anything that needs it
                if NOT(params.base_id EQ 0L) then $
                  widget_control, params.base_cols_id[0], sensitive=0
                if NOT(params.grid_id EQ 0L) then $
                  widget_control, params.grid_id, sensitive=0
                if NOT(params.manual_id EQ 0L) then $
                  widget_control, params.manual_id, sensitive=0
                if NOT(params.fname_id EQ 0L) then $
                  widget_control, params.fname_id, sensitive=0
                if NOT(params.auto_id EQ 0L) then $
                  for count = 0, 7 do widget_control, params.auto_rows_id[count], sensitive=0
                
                                ;  Make sure the stop flag is zero
                params.stop_flag = 0
                
                                ;  Generate a short timer event.  With the 'Start Scanning'
                                ;  button event handled, the manager will exit this event 
                                ;  handler, and come back to it quickly with a timer event, 
                                ;  which is handled above, and calls the scanning code.
                widget_control, ev.id, timer=0.1
                
            end
            'Stop Scanning':	begin
                params.stop_flag = 1
                widget_control, params.base_id, set_uvalue=params
                if NOT(params.base_id EQ 0L) then $
                  widget_control, params.base_cols_id[0], /sensitive
                if NOT(params.grid_id EQ 0L) then $
                  widget_control, params.grid_id, /sensitive
                if NOT(params.manual_id EQ 0L) then $
                  widget_control, params.manual_id, /sensitive
                if NOT(params.fname_id EQ 0L) then $
                  widget_control, params.fname_id, /sensitive
                if NOT(params.auto_id EQ 0L) then $
                  for count = 0, 7 do widget_control, params.auto_rows_id[count], /sensitive
                return
            end
            'Help':		create_help, params.base_id, ev.top
        endcase
    end
    else:
endcase

widget_control, params.base_id, set_uvalue=params ;  Update parameter structure

end





