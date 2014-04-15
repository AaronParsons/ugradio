pro lst, currentlst

;+
;print or return the current lst
;
;calling sequence: 
;
;	LST
;
;to get the lst returned to you, use LSTNOW
;-

print, 'current lst is ', lstnow(), ' hours.'

print, 'or ', sixty(lstnow())

return
end
