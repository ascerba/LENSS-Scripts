#!/bin/bash
# Generates a data report for a GLAS SQM
# Creates a text file with the report or sends an email with the data

read -p "Generate a text file or send report as an email? [t/e]: " outputOption
while [[ $outputOption != 't' && $outputOption != 'e' ]]; do
	read -p "Please enter a 't' or 'e': " outputOption
done

# 'Program installed' check from https://stackoverflow.com/questions/33297857/how-to-check-dependency-in-bash-script
if [[ $outputOption == 'e' ]] && ! command -v wget >/dev/null 2>&1
then
	echo "Error: Wget is not installed and is required to use the email feature.
Please install before using this feature."
	exit 1
fi

read -p "Enter name of sensor: " name

while ! [[ "$name" =~ ^[a-zA-Z0-9_-]+$ ]]
do
	read -p "Error: Name can only contain alphanumeric characters, '-', and '_'. Enter valid name: " name
done

read -p "Enter date of data (YYYY-MM-DD): " date

# Date check from https://unix.stackexchange.com/questions/236328/check-if-date-argument-is-in-yyyy-mm-dd-format
while ! [[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
do
	read -p "Error: Invalid date format. Enter new date (YYYY-MM-DD): " date
done

# TODO
# SQL Queries sent to csv file "$date$name.csv"
# Return and error if the name or date cannot be found in the database
# and ask for the user to re-enter the information.
# Upon valid query, save data to $date$name.csv

# TODO
# Handle incorrect file permissions
# Check that email was sent correctly or update status message

# Email REGEX loop from https://stackoverflow.com/questions/32291127/bash-regex-email
if [[ $outputOption == 'e' ]]
then
	wget -q --tries=10 --timeout=20 --spider http://google.com # Checks if client is connected to the internet
	
	if [[ $? -eq 0 ]]
	then
		read -p "Enter email to send report to: " email
		
		while ! [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; do
			read -p "Email address $email is invalid. Please enter a vaild email." email
		done
		
		echo "-- Sending report to $email..."
		cat $name"_Header.txt" $date$name.csv | mailx -v -s "$date $name DSA Report" $email
	else
		echo "Warning: No internet connection found. Saving to local file instead."
		cat $name"_Header.txt" $date$name.csv > $date"_"$name"_DSA_Report.txt"
		echo "-- File saved to ./$date"_"$name"_DSA_Report.txt""
	fi
else
	cat $name"_Header.txt" $date$name.csv > $date"_"$name"_DSA_Report.txt"
	echo "-- File saved to ./$date"_"$name"_DSA_Report.txt""
fi

