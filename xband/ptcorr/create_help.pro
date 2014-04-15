pro create_help, $
                 base_id, $
                 call_wid_id

widget_control, base_id, get_uvalue=params ;  Get parameter structure

help_id = widget_base(title='Help Me!!!', /column, group_leader=call_wid_id)

case call_wid_id of
    params.base_id: $
      values = ['BURAO 12 GHz Interferometer', $
                ' ', $
                'PoinTing CORRection Scanning', $
                ' ', $
                '     Use PTCORR---Scanning to configure and', $
                'perform scans for the sun and the moon.  The goal', $
                'of these scans is to derive the pointing constants', $
                'associated with the BURAO 12 GHz interferometer', $
                'antennas.', $
                ' ', $
                'Scan Types', $
                '  Manual:	Configure and perform an alt/az scan.', $
                '  Automatic:	Configure and perform many scans.', $
                ' ', $
                'Grid Parameters:	Configure grid size and', $
                '        spacing.', $
                'Progress:	Display the grid and scan progress.', $
                ' ', $
                'Other Buttons', $
                '  Quit:	Quit this program.', $
                '  Help:	Show this window.', $
                '  Stow:	Stow the antennas.']
    params.manual_id: $
      values = ['BURAO 12 GHz Interferometer', $
                ' ', $
                'Manual Scan Parameters', $
                ' ', $
                '       Perform single scans with this window.', $
                ' ', $
                'Filename:  File data is save to.', $
                'File Path:  Path to which data is save to.', $
                'Pointing Mode:  Specify in which mode, forward', $
                '       or reverse, the telescopes will scan.', $
                'Pointing Corrections:  Use this toggle to select', $
                '       the pointing constants used during the', $
                '       scan.  "All" will use all corrections,', $
                '       "None" will use no corrections and "Dial"', $
                '       will use only the dial offsets.', $
                'Object:  Select the object to be scanned.', $
                'Start Scan:	Start the scan as specified by the', $
                '       above parameters and the grid parameters.', $
                'Help:	Show this window.']
    params.auto_id: $
      values = ['BURAO 12 GHz Interferometer', $
                ' ', $
                'Automatic Scan Parameters', $
                ' ', $
                '       Perform multiple scans with this window.', $
                ' ', $
                'Filename:  File data is save to.  This filename', $
                '       is generated automatically based upon three', $
                '       fields plus a suffix.  Change the contents of', $
                '       the fields by pressing the CHANGE button.', $
                'File Path:  Path to which data is save to.', $
                'Initial File Number:  Specify the initial file', $
                '       number that data will be saved to.  Subsequent', $
                '       files will be saved with the file number', $
                '       incremented by one for each file.', $
                'Inter-Scan Delay:  Delay between successive sets of', $
                '       scans.', $
                'Pointing Mode:  Specify in which mode, forward', $
                '       or reverse, the telescopes will scan.  Select', $
                '       AUTO to let software scan in both modes, as', $
                '       pointing parameters allow.  A scan with AUTO', $
                '       set will only occur if both a forward and a', $
                '       reverse pointing is possible.', $
                'Pointing Corrections:  Use this toggle to select', $
                '       the pointing constants used during the', $
                '       scan.  "All" will use all corrections,', $
                '       "None" will use no corrections and "Dial"', $
                '       will use only the dial offsets.', $
                'Object:  Select the object to be scanned.', $
                '       Select AUTO to scan both the sun and moon', $
                '       as pointing parameters allow.', $
                'Auto Analysis:  Click on YES to analyze the data', $
                '       as each set of scans is being taken.  The', $
                '       Auto Analyzer will start looking for data files', $
                '       as soon as it comes up, and will continue to', $
                '       analyze as long as there are files in the queue.', $
                '       The queue can be cleared and analysis stopped by' , $
                '       clicking NO.  RE-RUN is used to run data back', $
                '       through the analyzer.  Set up the scan file path', $
                '       file number, inter-scan delay and analysis', $
                '       parameters as normal, and click on the START', $
                '       SCAN button.  This feature does not check for', $
                '       missing files and will crash if a file does', $
                '       not exist.', $
                'Start Scanning:  Start the scan as specified by the', $
                '       above parameters and the grid parameters.', $
                'Stop Scanning:  Stop the scanning process after', $
                '       current scan is complete.', $
                'Help:	Show this window.']
    params.grid_id: $
      values = ['BURAO 12 GHz Interferometer', $
                ' ', $
                'Gridding Parameters', $
                ' ', $
                '       Use this window to specify parameters about', $
                'size of the cross and the distance between samples.', $
                ' ', $
                'Size:  Control the number of samples taken in one', $
                '       direction (altitude or azimuth) of the scan.', $
                'Spacing:  The distance in degrees between', $
                '       adjacent samplings of the scan.  Note that the', $
                '       number displayed is ten times the actual value.', $
                'Help:	Show this window.']
    params.prog_id: $
      values = ['BURAO 12 GHz Interferometer', $
                ' ', $
                'Scan Grid/Progress', $
                ' ', $
                '       This window graphically displays what the scan', $
                'will look like.  The blue squares show where the', $
                'samples will be taken, and the red circle indicates', $
                'the size and expected placement of the object', $
                'relative to the scan grid.', $
                ' ', $
                '       As a scan is being conducted, the blue squares', $
                'will turn green to indicate that a sample has been', $
                'taken at that position.', $
                ' ', $
                'Help:	Show this window.']
    params.fname_id: $
      values = ['BURAO 12 GHz Interferometer', $
                ' ', $
                'Change File Name', $
                ' ', $
                '       Use this window to change the automatically', $
                'generated file name.  This file name consists of', $
                'three fields plus a suffix.  Each of the three', $
                'fields can be one of three choices that are inserted', $
                'depending on what is being observed (Source:  Sun,', $
                'moon) how it is being observed (Mode:  Forward,,', $
                'reverse) and the current file number.', $
                ' ', $
                '       The suffix is either .SAV of .DAT.  If .SAV is', $
                'chosen, the data will be saved in the IDL save file', $
                'binary format.  If .DAT is chosen, the data will be', $
                'saved as an ASCII text file.', $
                ' ', $
                '       An example file name is displayed below the', $
                'field choices.', $
                ' ', $
                'Buttons:', $
                '  Update Format:  Press this button to save the file', $
                '       format and close the window.', $
                '  Make No Changes:  Press this button to dismiss the', $
                '       window without making any changes.', $
                'Help:	Show this window.']
endcase



list = widget_text(help_id, /scroll, value=values, xsize=60, ysize=10)
junk = widget_button(help_id, value='Close This Goofy Help')

widget_control, help_id, /realize
xmanager, 'help', help_id, /no_block

end
