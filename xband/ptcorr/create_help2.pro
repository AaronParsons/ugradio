pro create_help2, $
                 base_id, $
                 call_wid_id

widget_control, base_id, get_uvalue=params ;  Get parameter structure

help_id = widget_base(title='Help Me!!!', /column, group_leader=call_wid_id)

case call_wid_id of
    params.base_id: $
      values = ['BURAO 12 GHz Interferometer', $
                ' ', $
                'PoinTing CORRection Analyzer', $
                ' ', $
                '     Use PTCORR---Analyzer to analyze data as it', $
                'is taken.  Filenumbers are written to a queue and', $
                'the analyzer will analyze all forward and reverse', $
                'files with that filenumber.', $
                '     Fits are saved to a file with "fit" inserted', $
                'into the original filename.', $
                ' ', $
                'Analysis Status:  In this window will be the', $
                '       current status of the analyzer.  It will read', $
                '       either:', $
                '          Run--Analyzer is checking queue for', $
                '               file numbers and will analyze', $
                '               data when found.', $
                '          Stop--Analyzer is not running', $
                '          File XXX--Analyzer is currently', $
                '               analyzing data in files with', $
                '               the file number, XXX.', $
                ' ', $
                'Data Display:  Open this window to view the data', $
                '       and the various fits being made to it.', $
                ' ', $
                'Baseline Fitting:  Open this window to examine', $
                '       and change parameters associated with', $
                '       removing a baseline from the data.', $
                ' ', $
                'Centroid and Corrections:  Open this window to', $
                '       examine and change the coordinate system', $
                '       (sky or encoder), the direction of increasing', $
                '       power and the file to which pointing errors', $
                '       and calculated corrections are saved.', $
                ' ', $
                'Pointing Constants:  Not implemented.', $
                ' ', $
                'Other Buttons', $
                '  Run:  Start the analyzer.  The analyzer will', $
                '        check the queue for new files to analyze.', $
                '  Stop:  Stop the analyzer.', $
                '  Clear Queue:  Clear the analyzer queue.', $
                '  Help:  Show this window.']
    params.line_id: $
      values = ['BURAO 12 GHz Interferometer', $
                ' ', $
                'Baseline Fitting', $
                ' ', $
                '       Use this window to control how baselines', $
                'are removed from the data.  Baselines are removed', $
                'by subtracting an n-order polynomial before a', $
                'Gaussian is fit to the data.', $
                '       The best baseline fit is determined by', $
                'examining the RMS of the Gaussian fit.  The', $
                'baseline removal that results in the smallest', $
                'RMS is used as the best baseline fit.', $
                ' ', $
                'Remove Baseline?  Use this toggle switch to turn', $
                '       fitting on and off.  With the fitting off,', $
                '       a Gaussian will be directly fitted to the', $
                '       data.', $
                ' ', $
                'Polynomial Order:  Choose the maximum order of the', $
                '       polynomial fit to the data.  The order of the', $
                '       is adjusted depending on the number of data', $
                '       points that are in the fit.  For example, if', $
                '       only two data points are used, the polynomial', $
                '       used is one--a line.', $
                ' ', $
                'Left Fit Points/Right Fit Points:  Choose the', $
                '       minimum and maximum number of points on the', $
                '       left and right sides of the scan that are', $
                '       used to create the baseline fit.  All', $
                '       combinations of minimum and maximum number', $
                '       of points will be tested.', $
                ' ', $
                'Help:	Show this window.']
    params.centroid_id: $
      values = ['BURAO 12 GHz Interferometer', $
                ' ', $
                'Centroid Locating', $
                ' ', $
                '       Use this window to control how the centroid', $
                'of a scan is found.  Currently, a Gaussian is fit', $
                'to the data and the center of the Gaussian is', $
                'taken as the center of the scan.', $
                ' ', $
                'Coordinate System:  Use this toggle to choose the', $
                '       system used to perform the fit.  Encoder', $
                '       coordinates refer to the direct reading of', $
                '       the encoders, with encoder pulses converted', $
                '       to angles.  For sky coordinates, the', $
                '       encoder coordinates are converted to sky', $
                '       coordinates using the pointing constants', $
                '       previously entered into the software.', $
                ' ', $
                'Power Increases:  Depending on the hardware setup,', $
                '       increasing system power output can increase', $
                '       either positively or negatively.  Toggle this', $
                '       switch to correspond to the system performance.', $
                '       For the Telonic XD-23E and XD-3E detectors', $
                '       commonly used for this application, power', $
                '       increases negatively.', $
                ' ', $
                'Corrections Log:  Contains the data file into which', $
                '       pointing errors and calculated corrections', $
                '       are placed.', $
                ' ', $
                'Help:  Show this window.']
    params.data_id: $
      values = ['BURAO 12 GHz Interferometer', $
                ' ', $
                'Data and Fits', $
                ' ', $
                '       Use this window to display baseline', $
                'and Gaussian fits.', $
                ' ', $
                'Raw Data:  These two windows display the output', $
                '       power data as a function of altitude or', $
                '       azimuth angle, drawn in green.  Ontop', $
                '       this is plotted the best baseline found', $
                '       in red.', $
                ' ', $
                'Fit Data:  These two windows display the ouput', $
                '       power data with the baseline removed in', $
                '       in blue.  Superimposed is the Gaussian', $
                '       fit to the data in yellow.  A white, vertical', $
                '       line indicates the expected position of the', $
                '       source.', $
                ' ', $
                'Help:  Show this window.']
                
    
endcase		



list = widget_text(help_id, /scroll, value=values, xsize=60, ysize=10)
junk = widget_button(help_id, value='Close This Goofy Help')

widget_control, help_id, /realize
xmanager, 'help', help_id, /no_block

end
