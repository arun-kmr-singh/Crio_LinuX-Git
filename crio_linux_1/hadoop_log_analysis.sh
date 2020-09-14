#!/bin/bash

# Usage: <location_of_script>/hadoop_log_analysis.sh <directory_to_use_for_files>

# Check if the command line parameter has been specified
if test $# -ne 1
   then
   echo "Incorrect invocation of script. Usage: <location_of_script>/hadoop_log_analysis.sh <directory_to_use_for_files>"
   exit 1  # Failure
fi

mkdir -p $1

echo -e "##################################################################\n\n"

# Fetch the log file bundle
echo -e "Downloading Hadoop Log files - Started\n"
wget https://zenodo.org/record/3227177/files/Hadoop.tar.gz -O "$1/Hadoop.tar.gz" -o /dev/null
# Untar and unzip the bundle to get the logs
tar -xvzf "$1/Hadoop.tar.gz" -C $1 > /dev/null
# You would see multiple directories, each containing multiple logs after this

echo -e "Downloading Hadoop Log files - Successful\n"

echo -e "##################################################################\n\n"
# How many log files do we have?
# Run the below from the directory where the subdirectories are present
echo -e "Number of log files"
cd $1
find $1 -type f -name *.log | wc -l

echo -e "##################################################################\n\n"
# Example to process all files fetched one by one
#for file in `find $1 -name *.log -type f`; do  echo "Processing $file" ; done

# Number of ERRORs seen across all logs
# Create the count_errors.sh script as show below and execute that
count=0
sum=0
for file in `find $1 -name *.log -type f`
do
        count=$(grep ERROR "$file"| wc -l)
        sum=$((sum + count))
done
echo -e "Number of total ERRORs seen \n$sum"
# Or run this command to count the ERRORs across logs
#grep -r ERROR $1 | wc -l
echo -e "Number of total FATAL messages seen"
grep -r FATAL $1 | wc -l
echo -e "Number of total WARNing messages seen"
grep -r WARN $1 | wc -l
echo -e "Number of total INFOrmational messages seen"
grep -r INFO $1 | wc -l

echo -e "##################################################################\n\n"

# How many “Exceptions” do you see?
echo -e "Number of Exceptions seen"
grep -r "Exception" $1 | wc -l

echo -e "##################################################################\n\n"
# Which of these exceptions are related to the disk being full?
echo -e "Number of Disk Full exceptions seen"
grep -r "Exception" $1 | grep disk | wc -l

#echo -e "##################################################################\n\n"
# Print out list of log filenames and count of how many exceptions are seen in that file, only if count is > 1
# echo -e "Logs files that have at least one Exception\n"
#grep -rc "Exception" $1 | grep -v ":0$"

echo -e "##################################################################\n\n"
# Print out list of log filenames and count of how many exceptions are seen in that file, only if count is > 1
# Print a Histogram of these counts per file
echo -e "LOG FILE HISTOGRAM WITH NUMBER OF EXCEPTIONS\n"
grep -rc "Exception" $1 | grep -v ":0$" > /tmp/histogram_input
sed -i 's/:/\t/g' /tmp/histogram_input
perl -lane 'print $F[0], "\t", "=" x ($F[1])' /tmp/histogram_input  2> /dev/null

echo -e "##################################################################\n\n"
# Filter out across the log file, all events that occured at a particular minute
# E.g. “2015-10-19 14:25”
# List all log names where this occurs
echo -e "Log File contents for the minute 2015-10-19 14:25 have been printed to the /tmp/minute_log file\n"
grep -ri "2015-10-19 14:25" $1 > /tmp/minute_log
echo -e "List of files that have log messages for the minute 2015-10-19 14:25\n"
grep -r "2015-10-19 14:25" $1 | awk -F ":" '{print $1}' | sort | uniq | grep "\.log"

echo -e "##################################################################\n\n"
# How many “MapTask metrics system” and “ReduceTask metrics system” shutdowns were completed?
# We grep the above strings and find that “shutdown complete” is what we need to look for
echo -e "Number of MapTask shutdowns seen"
grep -ri "shutdown complete" $1 | grep -c MapTask
echo -e "Number of ReduceTask shutdowns seen"
grep -ri "shutdown complete" $1 | grep -c ReduceTask

echo -e "##################################################################\n\n"