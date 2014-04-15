pro scanner_event, ev

widget_control, ev.top, get_uvalue=params
widget_control, ev.id, get_uvalue=uval

case strtrim(uval, 2) of
    'parameter':	begin
        case strtrim(ev.value, 2) of
            'Manual':	begin
                if ev.select then begin
                    widget_control, params.auto_id, bad_id=trash, /destroy
                    params.auto_id = 0L
                    widget_control, params.base_id, set_uvalue=params
                    create_manual, params.base_id
                    widget_control, params.base_id, get_uvalue=params
                endif
            end
            'Automatic':	begin
                if ev.select then begin
                    widget_control, params.manual_id, bad_id=trash, /destroy
                    params.manual_id = 0L
                    widget_control, params.base_id, set_uvalue=params
                    create_auto, params.base_id
                    widget_control, params.base_id, get_uvalue=params
                endif
            end
        endcase
    end
    'grid':	begin
        case 1 of
            (strtrim(ev.value, 2) EQ 'Open' AND ev.select):	begin
                create_grid, params.base_id
                widget_control, params.base_id, get_uvalue=params
            end
            (strtrim(ev.value, 2) EQ 'Close' AND ev.select):begin
                widget_control, params.grid_id, bad_id=trash, /destroy
                params.grid_id = 0L
                auto_rows_id = [0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L]
                widget_control, params.base_id, set_uvalue=params 
            end
            else:
        endcase
    end
    'prog':	begin
        case 1 of
            (strtrim(ev.value, 2) EQ 'Open' AND ev.select):	begin
                create_prog, params.base_id
                widget_control, params.base_id, get_uvalue=params
            end
            (strtrim(ev.value, 2) EQ 'Close' AND ev.select):begin
                widget_control, params.prog_id, bad_id=trash, /destroy
                params.prog_id = 0L
                params.win_num = -1
                widget_control, params.base_id, set_uvalue=params 
            end
            else:
        endcase
    end
    'system':	begin
        case strtrim(ev.value, 2) of
            'Quit':  begin
                ptr_free, params.ref, params.fpath_ref
                widget_control, params.base_id, bad_id=trash, /destroy
            end
            'Help':  create_help, params.base_id, params.base_id
            'Stow':  begin
                widget_control, /hourglass
                result=point2(/stow)
            end  
            'Home':  begin
                widget_control, /hourglass
                result=point2(/home, /verbose)
            end  
            
        endcase
    end
endcase

end


    
;	'analysis':	begin
;		case strtrim(ev.value, 2) of
;			'Input':	begin
;				if ev.select then begin
;					create_input, params.base_id
;					widget_control, params.base_id, get_uvalue=params
;				endif else begin
;					widget_control, params.input_id, bad_id=trash, /destroy
;					params.input_id = 0L
;					widget_control, params.base_id, set_uvalue=params 
;				endelse
;				end
;			'Baseline':	begin
;				if ev.select then begin
;					create_line, params.base_id
;					widget_control, params.base_id, get_uvalue=params
;				endif else begin
;					widget_control, params.line_id, bad_id=trash, /destroy
;					params.input_id = 0L
;					widget_control, params.base_id, set_uvalue=params 
;				endelse
;				end
;			'Centroid':	print, 'Coming soon!'
;			'Constants':	print, 'Hold your Horses!
;		endcase
;	end



