#!/bin/bash
#
# munkihelper-fix_missing_displayname.sh
#
# copies munki pkginfo 'name' to missing 'display_name'
#
# assumes that your pkginfo files are endind with .plist extension
# if your pkginfo files have no .plist extension then this will not do anything
#
# created by MiqViq on 2016-09-16
#

# IMPORTANT: set pkgsinfoDirPath to suit your environment
pkgsinfoDirPath=/Volumes/munki/repo/pkgsinfo

IFS=$'\n'

plistFiles=$(find "$pkgsinfoDirPath" -type f -iname *.plist)

for item in $plistFiles
do
	getMunkiItemName=$(defaults read "$item" name 2>/dev/null)
	
	# skip on missing item name
	if [ "" == "$getMunkiItemName" ]
	then
		continue
	fi

	getMunkiItemDisplayName=$(defaults read "$item" display_name 2>/dev/null)

	# if display_name is empty then copy name to display_name	
	if [ "" == "$getMunkiItemDisplayName" ]
	then
		echo "Pkginfo '$getMunkiItemName' is missing display_name, fixing it"
		defaults write "$item" display_name "$getMunkiItemName"
		
		# restore plist to XML format 
		plutil -convert xml1 "$item"
	fi
done
