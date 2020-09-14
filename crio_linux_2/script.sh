echo
read -p "Enter File Name: " filename

#flname=user_preference.py

echo
echo "Total Number of lines in $filename are : "
wc -l $filename

echo

echo "Total Number of Comments in $filename are: "
grep -c "#" $filename



