pro scan_it_all, $
                 head, $        ;  Header structure
                 dat, $         ;  Data structure
                 dir, $         ;  Horizontal or vertical scan direction
                 win_num        ;  Window number for status screen update


print, ' '
print, $
' COUNT  DIR  DELAZ  DELALT  PWR_E(mv)  PWR_W(mv)   AZ       ALT       LST'

tempalt = make_array(1, /float, value=0.0)
tempaz = make_array(1, /float, value=0.0)

if NOT(win_num EQ -1) then $
  wset, win_num

;print,'hoha1'

; FIRST HOME THE DISHES!

;print,'(scan_it_all line 18) sending dishes home'
;surehome


for count = 0, (head.size - 1) do begin
          ;  Calculate offset then make calculations to get alt-az.
    offset = (count - head.size / 2) * head.space

;print,'scan_it_all line 22 - offset:',offset
;!!!!!!!!!!! HERE I AM CHANGING THINGS TO USE AASUN IN REAL TIME.
    lst1=lstnow()

IF HEAD.MOON THEN BEGIN
    imoon,alt,az,/aa
    aanow=[alt,az]
ENDIF ELSE BEGIN
     isun,alt,az,/aa
     aanow=[alt,az]
ENDELSE

;STORE THE ACTUAL SOURCE ALT AND AZ...
dat.srcalt[ count, dir]= aanow[0]
dat.srcaz[ count, dir]= aanow[1]

                                ;  Calculate coordinates to send to
                                ;  point2setenv  IDL_PATH	
                                ; ${IDL_PATH}:/home/curt/radio/xband/alaz/idl
IF (DIR) THEN BEGIN
   dat.alt[count, dir] = aanow[0]
   dat.az[count, dir] = aanow[1] + offset
        IF OFFSET EQ 0.0 THEN BEGIN
            if head.reverse then head.s_az=pmod(aanow[1]+180.,360) $
              else head.s_az=aanow[1]
;            print,'(scan_it_all line 42) s_az:',head.s_az,head.reverse
        ENDIF
ENDIF ELSE BEGIN
   dat.alt[count, dir] = aanow[0] + offset
   dat.az[count, dir] = aanow[1]
        IF OFFSET EQ 0.0 THEN BEGIN
            if head.reverse then head.s_alt=180.-aanow[0] $
             else head.s_alt=aanow[0]
;            print,'(scan_it_all line 52) s_alt:',head.s_alt,head.reverse
        ENDIF
ENDELSE

;  Point the antenna

;NOW POINT THEM
;print, 'Pointing to alt, az:  ', dat[0].alt[count, dir], dat[0].az[count, dir]
CASE 1 OF
        HEAD.REVERSE: BEGIN
            point_result = point2(alt=dat[0].alt[count, dir], az=dat[0].az[count, dir],  $
                                  nocorrect=head.nocorrect, /reverse)
        END
        NOT(FLOAT(HEAD.REVERSE)):  BEGIN
            point_result = point2(alt=dat[0].alt[count, dir], az=dat[0].az[count, dir],  $
                                  nocorrect=head.nocorrect, /forward)
        END
ENDCASE
    
;print,'hoha3'
                                ;  Sample the output power.  Method:  
                                ;  Put the 150 MHz IF through a crystal
                                ;  switch, then a detector.  Sample
                                ;  the resulting voltages with the DVM.
;FLIP SWITCH TO EAST DISH AND READ THE HP DVM...
    result=spc(dig1=1)
    wait, 0.1
;    pwr=fltarr( 4)
;    FOR NR_INTEG=0,3 DO BEGIN 
;	pwr[nr_integ]= spc(/dvm) 
;;	wait, 0.5 
;    ENDFOR
;    dat[0].pow[count, dir]= median( pwr, /even)
    dat[0].pow[count, dir]= spc(/dvm)

;FLIP SWITCH TO WEST DISH AND READ THE HP DVM...
    result=spc(dig1=0)
    wait, 0.1
;    pwr=fltarr( 4)
;    FOR NR_INTEG=0,3 DO BEGIN 
;	pwr[nr_integ]= spc(/dvm) 
;;	wait, 0.5 
;    ENDFOR
;;    for nr_integ=0,3 do begin & pwr[nr_integ]= spc(/dvm) & print, nr_integ & endfor
;;    for nr_integ=0,3 do pwr[nr_integ]= spc(/dvm)
;    dat[1].pow[count, dir]= median( pwr, /even)
    dat[1].pow[count, dir]= spc(/dvm)   

;GET THE LST...
    lst2=lstnow()
                                ; Average and save the lsts
    dat.lst[count, dir] = (lst1 + lst2) / 2.
    
                                ;  Get alts and azes back from point2
    result = point2(/pos, /nocorrect)
    dat[0].unalt[count, dir] = result[0]
    dat[0].unaz[count, dir] = result[1]
    dat[1].unalt[count, dir] = result[2]
    dat[1].unaz[count, dir] = result[3]

;print,'scan_it_all L116, uncorrected w alt,az:'
;print,result[2],result[3]

    result = point2(/pos,reverse=head.reverse)
    dat[0].coralt[count, dir] = result[0]
    dat[0].coraz[count, dir] = result[1]
    dat[1].coralt[count, dir] = result[2]
    dat[1].coraz[count, dir] = result[3]

;PRINT OUT RESULTS FOR MONITORING PURPOSES...
print, count, dir, $
	dat[0].az[count,dir]-dat[0].srcaz[count,dir], $
	dat[0].alt[count,dir]-dat[0].srcalt[count,dir], $
	1e3*dat[0].pow[count,dir], 1e3*dat[1].pow[count,dir], $
	dat[0].az[count,dir], dat[0].alt[count,dir], dat[0].lst[count,dir], $
	format='( i4, i6, 2f8.2, f9.2, f11.2, 2f9.2, f9.3)'

;stop

                                ;  Find the lst just after the sampling
                                ;  Update status screen if it exists
	if NOT(win_num EQ -1) then begin
            ;print, 'scan_it_all', win_num
            wset, win_num
            if (dir) then begin
                tempaz[0] = offset
                tempalt[0] = 0
                oplot, tempaz, tempalt, psym=7, color=100
                oplot, tempaz, tempalt, psym=6, color=100
            endif else begin
                tempaz[0] = 0
                tempalt[0] = offset
                oplot, tempaz, tempalt, psym=7, color=100
                oplot, tempaz, tempalt, psym=6, color=100
            endelse
        endif
  endfor
    
    
end













