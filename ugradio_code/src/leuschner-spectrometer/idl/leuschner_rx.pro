;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This module is a very simple receiver function for Leuschner.
;; Copyright (C) 2014 Rachel Domagalski: idomagalski@berkeley.edu
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; ;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function leuschner_rx, filename, nspec, lonra, latdec, system 
    ; function leuschner_rx, filename, nspec, lonra, latdec, system 
    ; ==================================================================
    ;
    ; This function recieves data from the Leuschner spectrometer and
    ; saves it to a FITS file. The first HDU of the FITS file contains
    ; information about the observation, such as the coordinates, the 
    ; number of integrations accumulated, and attributes about the
    ; spectrometer used to collect the data. Each set of spectra is
    ; stored in its own FITS table in the FITS file. The columns in
    ; each FITS table are auto0_real, auto1_real, cross_real, and 
    ; cross_imag, and all of the columns contain double-precision
    ; floating-point numbers.
    ;
    ; Inputs:
    ; - filename: Name of the output FITS file.
    ; - nspec: Number of spectra to collect.
    ; - lonra: Either galacic longitude or right ascension, in degrees.
    ; - latdec: Either galactic latitude or declination, in degrees.
    ; - system: Coordinate system of coordinates. Either ga or eq.
    ; ==================================================================

    ; Check that the coordinate system is valid.
    if system ne "ga" and system ne "eq" then begin
        print, "ERROR: Invalid coordinate system: " + system
        return, 1
    endif

    ; Create a FITS primary header for the observation attributes
    fxhmake, header
    sxaddpar, header, "NSPEC", long(nspec)
    sxaddpar, header, "COORDSYS", system

    ; Coordinates
    if system eq "ga" then begin
        sxaddpar, header, "L", double(lonra)
        sxaddpar, header, "B", double(latdec)
    endif else begin
        sxaddpar, header, "RA",  double(lonra)
        sxaddpar, header, "DEC", double(latdec)
    endelse

    ; Create a temporary file for the observation attributes
    tmpfile = "/tmp/obs" + string(long(systime(/seconds))) + ".fits"
    tmpfile = repstr(tmpfile, " ", "")
    fits_write, tmpfile, 0, header

    ; Run the spectrometer receiver
    cmd = "leuschner_rx.py " + tmpfile + " " + filename
    spawn, cmd, exit_status=status
    file_delete, tmpfile
    return, status
end
