The dish control software (the primary program is dish.pro,
instructions for it are at
http://ugastro.berkeley.edu/radio/leuschner/pointing.html). 

<h1>Pointing the HI Leuschner Radio Dish</h1>
<p>
Pointing the radio dish requires logging into heiles.berkeley.edu (see <a
href="spechowto.pdf">datataking</a> for instructions on creating the remote
connection). The Leuschner radio dish is controlled through IDL using the following
suite of commands:
<p>
<table>
  <tbody>
    <tr><th>IDL Procedure/Function<th>syntax<th>example<th>description
                        <tr><td>dish.pro<td>dish, alt=value, az=value, /home, 
                                    move_check = move_check
                                    <td>dish, alt=65, az = 120
      <td>Points the dish to the requested alt and az.
      Further functionality for maintenance can
      be found in dish.pro<p>
      Use the /home keyword to home or stow the dish.<p>
      Use move_check to see if coordinates are reachable by the telescope. Returns 1 for accessible, -1 for inaccessible.<br>
      IDL&gt; move_check = 1<br>
      IDL&gt; dish, alt = 80, az = 270, move_check = move_check<br>
      IDL&gt; help, move_check<br>
      MOVE_CHECK        INT     =       1


    </tr>
    <tr><td>isun.pro<td>isun, coord1, coord2 [,/aa]
        <td>isun, ra, dec<br>isun, alt, az, /aa<br>&nbsp;
    <td>Stores the ra and dec of the sun in <i>ra</i> and
    <i>dec</i><br>Stores the alt and az of the sun (with keyword aa) in
    <i>alt</i> and <i>az</i><br>More thorough documention can be found in isun.pro
    </tr>
    <tr><td>imoon.pro<td>imoon, coord1, coord2 [,/aa]
        <td>imoon, ra, dec<br>imoon, alt, az, /aa<br>&nbsp;
    <td>Stores the ra and dec of the moon in <i>ra</i> and
    <i>dec</i><br>Stores the alt and az of the moon (with keyword aa) in
    <i>alt</i> and <i>az</i><br>More thorough documention can be found in imoon.pro
    </tr>
    <tr><td>ilst.pro<td>lst=ilst([juldate=value])<td>lst =
        ilst(juldate=2454140.5)
        <td>Returns the decimal hours of the local sidereal time at Campbell
    Hall for the specified julian date (or current LST if <i>juldate</i> is
    not given).  More thorough documentation can be found in ilst.pro
    </td>
    </tr>
    <tr><td>systime<td>time = systime([/seconds] [,/julian] [,/utc])
        <td>time = systime(/seconds)<br>time = systime(/julian, /utc)
    <td>Returns the number of seconds since 1 Jan 1970<br>Returns the
    julian date (corrected for UTC if the keyword is set)<br>This is a
    native IDL command
    </tr>
    <tr><td>sixty.pro<td>hms = sixty(value)<td>hms = sixty(17.345)
        <td>Converts a decimal <i>value</i> and returns a sexigesimal array
    </tr>
    <tr><td>ten.pro<td>h_decimal = ten(array)<td>h_decimal = ten([1,45,12])
        <td>Converts a sexigesimal <i>array</i> and returns a decimal value
    </tr>
<!--    <tr><td>cover.pro<td>viewable = cover(alt, az)<td>viewable =
            cover(45.,180.)
        <td>Returns a value of -1 if the given alt,az pair is unobservable, 0
    if the given alt,az pair is viewable
    </tr> -->
  </tbody>
</table>
<p>
<br>
</body>
</html>
