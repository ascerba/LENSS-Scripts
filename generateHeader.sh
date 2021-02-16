#!/bin/bash
# Generates a properly formatted header for a GLAS SQM
# per the DSA standards

read -p "Enter new sensor name (only alphanumeric, \"-\", and \"_\"): " sensorName

touch "$sensorName"_Header.txt
headerFile="$sensorName"_Header.txt

echo "# Community Standard Skyglow Data Format 1.0
# URL: https://www.darksky.org/wp-content/uploads/bsk-pdf-manager/47_SKYGLOW_DEFINITIONS.PDF
# Number of header lines: 35
# This data is released under the following license: ODbL 1.0 http://opendatacommons.org/licenses/odbl/summary/
# Device type: GLAS-SQM
# Instrument ID: $sensorName" > $headerFile

read -p "Enter name(s) of the data providers / affiliated institution: " dataSupplier
while ! [[ "$dataSupplier" =~ ^[a-zA-Z0-9_-]+$ ]]
do
	read -p "Error: Field can only contain alphanumeric characters, '-', and '_'. Enter a valid entry: " dataSupplier
done
echo "# Data supplier: $dataSupplier" >> $headerFile

read -p "Enter the location as Country-State-City: " location
while ! [[ "$location" =~ ^[a-zA-Z0-9_-]+$ ]]
do
	read -p "Error: Field can only contain alphanumeric characters, '-', and '_'. Enter a valid entry: " location
done
echo "# Location name: $location" >> $headerFile

echo "--Enter exact position of sensor--"
read -p "Longitude (four decimals): " lon
while ! [[ "$lon" =~ ^[0-9-+].[0-9]{4}+$ ]]
do
	read -p "Error: Field must be formatted as a float to four decimal places. Enter a valid value: " lon
done
read -p "Latitude (four decimals): " lat
while ! [[ "$lat" =~ ^[0-9-+].[0-9]{4}+$ ]]
do
	read -p "Error: Field must be formatted as a float to four decimal places. Enter a valid value: " lat
done
read -p "Elevation in meters (whole number): " elev
while ! [[ "$elev" =~ ^[0-9]+$ ]]
do
	read -p "Error: Field must be formatted as a non-negative whole number. Enter a valid value: " elev
done
echo "# Position (lat, lon, elev(m)): $lon, $lat, $elev" >> $headerFile

read -p "Enter local timezone of the sensor's location as Country/Region (EX: America/Chicago): " timezone
while ! [[ "$timezone" =~ ^[a-zA-Z]/[a-zA-Z]+$ ]]
do
	read -p "Error: Timezone must be formatted as Country/Region. Enter a valid value: " timezone
done
echo "# Local timezone: $timezone" >> $headerFile

read -p "Enter the time synchonization method for the sensor (EX: GPS): " timeSync
while ! [[ "$timeSync" =~ ^[a-zA-Z]+$ ]]
do
	read -p "Error: Time sync method must be formatted as a single word or acronym. Enter a valid value: " timeSync
done
echo "# Time Synchronization: $timeSync" >> $headerFile

read -p "Is the sensor moving or stationary [ M / S ]: " positionMethod
while ! [[ "$positionMethod" =~ ^[mMsS]{1}+$ ]]
do
	read -p "Error: Entry is invalid. Enter and M or S: " positionMethod
done
if [[ "$positionMethod" =~ ^[sS]{1}+$ ]]
then
	echo "# Moving / Stationary position: STATIONARY" >> $headerFile
else if [[ "$positionMethod" =~ ^[mM]{1}+$ ]]
	echo "# Moving / Stationary position: MOVING" >> $headerFile
fi

read -p "Is the sensor's look direction moving or fixed (MOVING / FIXED): " lookMethod
while ! [[ "$lookMethod" =~ ^[mMfF]+$ ]]
do
	read -p "Error: Entry is invalid. Enter and M or F: " lookMethod
done
if [[ "$lookMethod" =~ ^[fF]{1}+$ ]]
then
	echo "# Moving / Stationary position: FIXED" >> $headerFile
else if [[ "$lookMethod" =~ ^[mM]{1}+$ ]]
	echo "# Moving / Stationary position: MOVING" >> $headerFile
fi

read -p "Enter the number of viewing channels on the sensor (typically 1): " numChannels
while ! [[ "$numChannels" =~ ^[0-9]+$ ]] && [[ "$numChannels" == 0 ]]
do
	read -p "Error: Invalid number. Enter a non-zero, positive integer: " numChannels
done
echo "# Number of channels: $numChannels" >> $headerFile

echo "--Enter the type of filter on each channel--"
filterList=""
for ((i = 0; i < $numChannels; i++)); do
	printf "Channel %d\n" $(( i + 1 ))
	read -p "Enter filter type: " filter
	while ! [[ "$filter" =~ ^[a-zA-Z0-9-_]+$ ]]
	do
		read -p "Error: Filter type can only contain alphanumeric characters and '-' and '_'. Re-enter: " filter
	done
	if [[ $i == $(( numChannels - 1 )) ]]; then
		filterList="$filterList$filter"
	else
		filterList="$filterList$filter, "
	fi
done
echo "# Filter per channel: $filterList" >> $headerFile

echo "--Enter the measurement angles for the sensor channels as a signed float to 4 decimal places--"
directionList=""
for ((i = 0; i < $numChannels; i++)); do
	printf "Channel %d\n" $(( i + 1 ))
	read -p "Enter northern angle: " northAngle
	while ! [[ "$northAngle" =~ ^[0-9-].[0-9]{2}+$ ]]
	do
		read -p "Error: Number must be a signed float to two decimal places. Re-enter: " northAngle
	done
	read -P "Enter eastern angle: " eastAngle
	while ! [[ "$eastAngle" =~ ^[0-9-].[0-9]{2}+$ ]]
	do
		read -p "Error: Number must be a signed float to two decimal places. Re-enter: " eastAngle
	done
	if [[ $i == $(( numChannels - 1 )) ]]; then
		directionList="$directionList$northAngle, $eastAngle"
	else
		directionList="$directionList$northAngle, $eastAngle; "
	fi
done
echo "# Measurement direction per channel: $directionList" >> $headerFile

echo "--Enter the field of view of each sensor channel in degrees to 1 decimal place--"
fieldsOfView=""
for ((i = 0; i < $numChannels; i++)); do
	printf "Channel %d\n" $(( i + 1 ))
	read -p "Enter field of view: " fov
	while ! [[ "$fov" =~ ^[0-9]+$ ]]
	do
		read -p "Error: Number must be an unsigned whole number greater than zero. Re-enter: " fov
	done
	if [[ $i == $(( numChannels - 1 )) ]]; then
		fieldsOfView="$fieldsOfView$fov"
	else
		fieldsOfView="$fieldsOfView$fov, "
	fi
done
echo "# Field of view (degrees): $fieldsOfView" >> $headerFile

read -p "Enter the number of fields per data line (typically 6): " dataLineFields
echo "# Number of fields per line: $dataLineFields" >> $headerFile

read -p "Enter GLAS-SQM serial number: " serialNum
echo "# GLAS-SQM serial number: $serialNum" >> $headerFile

read -p "Enter GLAS-SQM firmware version: " firmwareRev
echo "# GLAS-SQM firmware version: $firmwareRev" >> $headerFile

read -p "Enter GLAS-SQM cover offset value: " coverOffset
echo "# GLAS-SQM cover offset value: $coverOffset" >> $headerFile

read -p "Enter the GLAS-SQM's test data line: " dataLine
while [[ $(echo $dataLine | awk -F ";" '{ print NF; exit }') != $dataLineFields ]]
do
	read -p "Data line must contain $dataLineFields fields. Please re-enter line: " dataLine
done
echo "# GLAS-SQM readout test: $dataLine" >> $headerFile

read -p "(Optional) Comment line 1 of 5: " comment1
echo "# Comment: $comment1" >> $headerFile

read -p "(Optional) Comment line 2 of 5: " comment2
echo "# Comment: $comment2" >> $headerFile

read -p "(Optional) Comment line 3 of 5: " comment3
echo "# Comment: $comment3" >> $headerFile

read -p "(Optional) Comment line 4 of 5: " comment4
echo "# Comment: $comment4" >> $headerFile

read -p "(Optional) Comment line 5 of 5: " comment5
echo "# Comment: $comment5" >> $headerFile

echo "# blank line 28
# blank line 29
# blank line 30
# blank line 31
# blank line 32" >> $headerFile

echo "Enter the data line format in plain text with comma field separators:"
echo "[Example] UTC Date & Time, Local Date & Time, Temperature, Counts"
read plainTextFormat
while [[ $(echo $plainTextFormat | awk -F "," '{ print NF; exit }') != $dataLineFields ]]
do
	echo "Text format linem must contain $dataLineFields fields. Please re-enter line:"
	read plainTextFormat
done
echo "# $plainTextFormat" >> $headerFile

echo "Enter the data line format with placeholders and semicolon field separators:"
echo "[Example] YYYY-MM-DDTHH:mm:ss.fff;YYYY-MM-DDTHH:mm:ss.fff;Celsius;number"
read placeholderFormat
while [[ $(echo $placeholderFormat | awk -F ";" '{ print NF; exit }') != $dataLineFields ]]
do
	echo "Text format linem must contain $dataLineFields fields. Please re-enter line:"
	read placeholderFormat
done
echo "# $placeholderFormat" >> $headerFile

echo "# END OF HEADER" >> $headerFile

echo "--Your generated file--"
cat $headerFile
