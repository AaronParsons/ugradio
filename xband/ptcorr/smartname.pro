function smartname,path,input,extension,forcepath=forcepath,forceext=forceext,dot=dot,slash=slash,verbose=verbose,mixpath=mixpath,mixext=mixext,getpath=getpath

;+
; NAME:
;               smartname
; PURPOSE:  
;               A case checking routine which will return a full
;               path\filename.extension given a default path and
;               extension and a filename of unknown format
;
; EXPLANATION:
;               This function is designed for use in programs which
;               read or write files based upon user input.  It accepts
;               a string representing a filename with or without path
;               and or extension information, and returns a string
;               suitable for use in commands such as save, restore,
;               etc.  Normally, if the the filename includes a path
;               and or extension, they are used.  Otherwise the
;               defaults are used.  The forcepath and forceext
;               keywords cause the program to return the respective
;               defaults no matter what is specified in the filename.
;               The mixpath and mixext commands return a combination
;               of the defaults and user input.  If called with only
;               two parameters, it will format a path instead of a
;               filename.  In this mode, it will append the user input
;               to the path variable unless the user input begins with
;               a slash or a '~', in which case the user input alone
;               is returned. 
;
; CALLING SEQUENCE:
;               result=smartname(path,input,extension)
; INPUTS:
;               path - a string containing the default path information.
;                       (the concluding \ is optional)
;               input - a string containing the filename
;               extension - a string containing the default extension.
;                       (the opening . is optional.)
;
;               IF ONLY TWO inputs are specified, smartname retuns a
;               directory name, such as '/home/path/dir/'
;
; OPTIONAL INPUT KEYWORDS:
;               \forcepath - always uses default path, no matter what path was included with the filename
;               \forceext - always uses the default extension, no matter what extension was included with the filename
;               \mixpath - adds whatever directories are included in input behind the default path
;               \mixext - adds the default extension behind any extension included in the input
;               \verbose - useful for debugging
;               dot='string' - defines the dot character
;               slash='string' - defines the slash character
; OUTPUTS:
;               result - a string containing the full path, filename, and extension.
; EXAMPLES: ----note this version has been modified to use a backslash----
;
;               IDL> print,smartname('c:\','hello','.txt')
;               c:\hello.txt
;
;               IDL> print,smartname('c:','hello','txt')
;               c:\hello.txt
;
;               IDL> print,smartname('c:\','d:\directory\hello.dat','.txt')
;               d:\directory\hello.dat
;
;               IDL> print,smartname('c:\','d:\directory\hello.dat','.txt',/forceext,/forcepath)
;               c:\hello.txt
;
;               IDL> print,smartname('c:\','directory\hello.dat','.zip',/mixext,/mixpath)
;               c:\directory\hello.dat.zip
;
;               IDL> print,smartname('http://kepler.lbl.gov','exp','.html',slash='/')
;               http://kepler.lbl.gov/exp.html

;               IDL> print,smartname('./','testdir')
;               ./testdir/

;               IDL> print,smartname('./','~/home/testdir')
;               ~/home/testdir
;
;
; RESTRICTIONS:
;               If /forceext is used and the input has several extensions, only the 
;               right-most extension is removed.  
;
;               Care should be taken when using the /mix and /force keywords - 
;               case checking is less thorough
;
; PROCEDURES CALLED
;               none 
; REVISION HISTORY:
;               Written by Erik Shirokoff (shiro@uclink4.berkeley.edu) on May 08,2000
;               modified August 9,2000 to include mix keywords
;               this version modified Aug 24 to use backslash as
;               default 
;               modified 5,2001 to include two-input case (directory
;               style) - ES
;-

;;defines the default slash and dot characters
if keyword_set(slash) eq 0 then slash='/'
if keyword_set(dot) eq 0 then dot='.'

;;insures there is a dot in the extension variable
edot=rstrpos(extension,dot)
if edot eq -1 then extension='.'+extension

;;insures there is a slash in the path variable
pslash=rstrpos(path,slash)
plast=strlen(path)-1
if pslash ne plast then path=path+slash

name=input

if n_params() eq 3 then begin
;;handles the path part of the input
    islash=rstrpos(input,slash)
    if islash eq -1 then begin
        name=path+name
    endif else begin
        if keyword_set(forcepath) ne 0 then begin
            name=strmid(name,islash+1)
            name=path+name
        endif else begin
            if keyword_set(mixpath) ne 0 then begin
                if strpos(name,slash) eq 0 then name=strmid(name,1)                     
                name=path+name
            endif
        endelse

    endelse


;FULL FILENAME

;;handles the extension part of the input
    idot=rstrpos(name,dot)
    if (idot eq -1 or idot lt rstrpos(name,slash)) then begin
        name=name+extension
    endif else begin
        if keyword_set(forceext) ne 0 then begin
        ;print,keyword_set(forceext)
            name=strmid(name,0,idot)
            name=name+extension
        endif else begin
            if keyword_Set(mixext) ne 0 then begin
                name=name+extension
            endif
        endelse
    endelse
endif


;;PATH ONLY MODE
if n_params() eq 2 then begin
    if strcmp(input,'') then begin
        name=path 
    endif else begin
            sl=strlen(input)
            strend=strmid(input,sl-1,1)
            haveslash=stregex(strend,'/',/boolean)
            if haveslash eq 0 then fname=name+'/' else fname=name
            name=path+fname
            strbegin=strmid(input,0,1)
            startingslash=stregex(strbegin,'/',/boolean)
            startingtwiddle=stregex(strbegin,'~',/boolean)
            startingds=stregex(strmid(input,0,2),'./',/boolean)
            if startingslash or startingtwiddle or startingds then name=fname
        endelse
endif


;;debugging stuff
if keyword_set(verbose) ne 0 then begin
        help,pslash,edot,edot,idot,islash,dot,slash
        help,path,input,extension,name
endif


;return path stuff
if keyword_set(getpath) then begin
    lstslash=rstrpos(input,slash)
    if lstslash ne -1 then begin
        userspath=strmid(input,0,lstslash+1)
        name=userspath
    endif else begin
        name=path
    endelse

endif    


return,name
end








