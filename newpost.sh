#!/bin/sh
postname=
while [ -z "$postname" ] ; do
	echo -n "Enter post name, e.g. what-i-learned-2020-01-01"
	read postname
done
../../bin/hugo new posts/${postname}.md || exit
echo "Created posts/%postname%.md"
"/c/Program\ Files/Notepad++/notepad++.exe" server.sh
# set /p postname="Enter post file name: "
# IF [%postname%] == [] GOTO finish
# ..\..\bin\hugo new posts/%postname%.md
# echo Created posts/%postname%.md
# "C:\Program Files\Notepad++\notepad++.exe" content\posts\%postname%.md
# :finish
# pause