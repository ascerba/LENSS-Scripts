# LENSS-Scripts
Scripts and server utilities for the LENSS project. [Main repo](https://github.com/yerkesobservatory/lenss-sensor).
These scripts assist with report generation for data submission to the Dark Sky Association (DSA). The header contents are based on the guidelines on their [website](https://www.darksky.org/light-pollution/measuring-light-pollution/).

## Header Generation Script
Interactive script that generates a complete DSA report header with the provided information. Header is saved in a file with a name sensor-name\_Header.txt
### Required Info
* Name of sensor (no special characters or whitespace)
* Location and setup data
* Test data line

## Report Generation Script
Interactive script that generates a DSA report from a header and dataset. The report is then saved as a text file or is emailed to the specified email address.
### Required Info
* Name of sensor (as entered in the header)
* Date of needed data (YYYY-MM-DD)
* Email address (optional)
