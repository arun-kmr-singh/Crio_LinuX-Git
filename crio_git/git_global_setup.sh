read -p "Username :" uname
read -p "User email :" uemail

git config --global user.name "$uname"
git config --global user.email "$uemail"
