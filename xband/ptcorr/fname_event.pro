pro fname_event, ev
flag = 0
widget_control, ev.top, get_uvalue=q
widget_control, ev.id, get_uvalue=uval

case uval of
	'update':	begin
		q.params.fields[*,1] = q.params.fields[*,0]
		widget_control, q.params.auto_fname, set_value=q.params.examp
		widget_control, ev.top, bad_id=trash
		if NOT(float(trash)) then $
			widget_control, ev.top, /destroy
		q.params.fname_id = 0L
		widget_control, q.params.base_id, set_uvalue=q.params
		end
	'cancel':	begin
		widget_control, ev.top, bad_id=trash
		if NOT(float(trash)) then $
			widget_control, ev.top, /destroy
		q.params.fname_id = 0L
		widget_control, q.params.base_id, set_uvalue=q.params
		end
	'help':		create_help, q.params.base_id, q.params.fname_id
	'field0': if ev.select then flag = 1
	'field1': if ev.select then flag = 3
	'field2': if ev.select then flag = 5
	'suffix': if ev.select then flag = 7
endcase

if flag then begin
	q.params.examp = ''
	q.params.fields[(flag - 1) / 2,0] = ev.value
	for count = 0, 2 do begin
		q.params.examp = q.params.examp + q.params.fvalues[q.params.fields[count,0], 1]
	endfor
	q.params.examp = q.params.examp + '.' + q.params.suffix[q.params.fields[3,0]]
	widget_control, q.text_wid, set_value=q.params.examp
	widget_control, ev.top, set_uvalue=q
endif

end
