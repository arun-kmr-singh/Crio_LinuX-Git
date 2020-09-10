echo  >> memdata.txt
date >> memdata.txt
grep MemTotal /proc/meminfo >> memdata.txt
grep MemFree /proc/meminfo >> memdata.txt
grep MemAvailable /proc/meminfo >> memdata.txt

#  '>>' used to append data to same file.

