;+
; NAME: scanner
;
; PURPOSE: 
;       performs automated drift scans across the sun and moon with
;       the 12 GHz dishes in order to obtain pointing corrections
;
; EXPLANATION: 
;       this is a widget based program with lots of parts.  Run the
;       program and select HELP in order to get a description of its
;       use, and see the document "A Recipe For Pointing Corrections"
;       for a description of how to obtain pointing constants from the
;       data.  Here I will only present a list of how to change  some of
;       the things that you might want to change when modifying this
;       program.  If you are as bad at widget stuff as I, it might be
;       useful. 
;
; CALLING SEQUENCE: scanner
;
; POSSIBLE MODIFICATIONS: (or, "where the hell is . . .")
;       
;       Scan/grid parameters - the default values live in scanner.pro
;                               The min and max values are in create_grid.pro.
;       Details of a scan - scan.pro finds the sun and moon, calls
;                           scan_it_all.pro which does the actual
;                           scanning, and then saves the data.
;       Delays - the default delay lives in scanner.pro. The actual
;                delaying happens in auto_event.pro
;       Auto source behavior - deciding what to scan happens in
;                              auto_event.pro
;       min and max alt and az - defined in repeat_scanner.pro
;       
;       
;
; REVISION HISTORY: Writen by Curtis Frank in 97 or 98.  Modified by
; Erik Shirokoff, summer 2001.
;-
pro scanner

params=	{base_id:	0L, $   ;  Base Widget ID
         manual_id:	0L, $   ;  Manual Scan Widget
         grid_id:	0L, $   ;  Grid Parameters Widget ID
         prog_id:	0L, $   ;  Draw Widget ID
         auto_id:	0L, $   ;  Auto Scan Widget ID
         fname_id:	0L, $   ;  Change File Name ID
         data_id:	0L, $   ;  Data Display ID
         anal_id:	0L, $   ;  Analysis Widget ID
         auto_rows_id:	[0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L], $	;  Auto Scan Row IDs
         base_cols_id:	[0L, 0L, 0L, 0L], $ ;  Base Column IDs
         auto_fname:	0L, $   ;  File Text Field ID
         auto_fnum:	0L, $   ;  File Number Field ID
         auto_anal:	0L, $    ;  Auto Analysis Flag
         i_fname:	0L, $   ;  File Field ID in Input Window
         i_forfname:	'', $   ;  Forward File Field text in Input Window
         i_revfname:	'', $   ;  Reverse File Field text in Input Window
         win_num:	-1, $   ;  Grid Draw Window Number
         data_win:	[-1, -1, -1, -1], $ ;  Data Draw Window Number
         size:		30, $   ;  Size
         space:		0.5, $  ;  Spacing
         delay:		5, $  ;  Auto scanning delay time
         fnum:		1L, $   ;  Initial File Number
         fields:	[[0, 2, 1, 0], [0, 2, 1, 0]], $
         fvalues:	[['Source', 'Mode', 'Number'], $
                         ['sun', 'for', '1'], $
                         ['moon', 'rev', '1']], $
         suffix:	['sav', 'dat'], $
         examp:		'sun1for.sav', $
         a_fpath:	'./', $
         a_mode:	2, $    ;  Auto Mode flag
         a_correct:	1, $    ;  Auto Pointing correction flag
         a_source:	2, $    ;  Auto Source flag
         m_mode:	0, $    ;  Manual Mode flag
         m_correct:	1, $    ;  Manual Pointing correction flag
         m_source:	0, $    ;  Manual Source flag
         m_fpath:	'./', $ ;  Manual File path
         m_fname:	'scan.sav', $ ;  Manual File name
         stop_flag:	0, $    ;  Auto stop flag
         test:		0, $    ;  Software test flag.  Set to 1 if testing
         ref:		ptr_new(-1), $ ;  Pointer to scanned file numbers
         fpath_ref:	ptr_new('')} ;  File path pointer

;  Create the tippy-top widget
base_id = widget_base(/column, title='PTCORR---Scanner')
r1 = widget_base(base_id, /row, group_leader=base_id)
junk = widget_label(r1, value='Scan Type:', xsize=144)
junk = cw_bgroup(r1, ['Automatic', 'Manual'], set_value=0, $
                 /row, uvalue='parameter', /return_name, /exclusive)
r2 = widget_base(base_id, /row, group_leader=base_id)
junk = widget_label(r2, value='Grid Parameters', xsize=144)
junk = cw_bgroup(r2, ['Open', 'Close'], /row, uvalue='grid', set_value=1, $
                 /return_name, /exclusive)
r3 = widget_base(base_id, /row, group_leader=base_id)
junk = widget_label(r3, value='Scan Grid/Progress', xsize=144)
junk = cw_bgroup(r3, ['Open', 'Close'], /row, uvalue='prog', set_value=1, $
                 /return_name, /exclusive)
r4 = widget_base(base_id, /row, group_leader=base_id, /align_center)
junk = cw_bgroup(r4, ['  Stow  ', '  Quit  ', '  Help  '], $
                 /row, uvalue='system', /return_name)

*params.fpath_ref = params.a_fpath ;  Kludge, I know.
params.base_cols_id = [r1, r2, r3, r4]
params.base_id = base_id
widget_control, base_id, set_uvalue=params
widget_control, base_id, /realize
xmanager, 'scanner', base_id, /no_block
create_auto, params.base_id
widget_control, base_id, get_uvalue=params
;params.anal_id = analysis(params.ref, params.fpath_ref, params.base_id)
;TO MAKE AUTO ANALYSIS THE DEFAULT, UNCOMMENT THE ABOVE AND CHANGE
;LINE 38 IN CREATE_AUTO.PRO - ES
params.auto_anal = 1
widget_control, base_id, set_uvalue=params


end








