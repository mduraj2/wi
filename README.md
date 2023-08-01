# work instruction

This little app allows a user to open the work instruction from the station based on the line/product/mode.
The idea behind is that instead of a paper copy we can use the digital version. Also, every time the product/line mode/version changes we should collect the previous WIs and provide with new ones.
It is very time consuming and allows old WIs to hang around.

The serial number needs to be added to:
db: general
table: stations
columns: id, station, serial_number, path, ip_address
WHERE & ip_address can be set to whatever e.g. 'NA'
AND station needs to have a structure like 'place_line_type' e.g. 'NLDC_NL07_SORTATION-IN' OR 'NLDC_NL07_SORTATION-OUT'
AND path = 'line/path_to_WI' e.g. 'NL03/OVERBOX LABELS'

The ip of the sharing mac is 172.30.1.199 and the user/password that is allowed to open the work instruction is apple/apple.

Much better idea of this would be to create a website that display a work instruction based on ip address/line mode/product etc.
The work instructions could be split to small modules and those modules could be called depending on ip address/line mode/product and listed in the browser.
e.g. a station would call modules # 1,2,3 and another station would call # 1,2,30,41 depending on the content.
