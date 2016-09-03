#!/bin/bash

# create_munki_grouped_items_install_manifests.sh

# create manifests that contain all the munki items within a pkgsinfo directory that are not update_for

echo "CREATING DIRECTORY GROUP ITEMS INSTALL MANIFESTS FOR MUNKI..."

munkiRepoDir="/path/to/munki/repo"

dirToCreateManifests="$HOME/Desktop/munki_grouped_items_install_manifests"

addCatalog=REQUIRED_CATALOG_NAME

mkdir -p -m 0777 "$dirToCreateManifests"

IFS=$'\n'

scanDirs=$(find "$munkiRepoDir/pkgsinfo" -type d | egrep -v "/pkgsinfo$|/$" | sort -u )  # use additional egrep -v (|) here to skip unwanted items

for subDir in $scanDirs
do
	getPkgsInfoFiles=$(find "$subDir" -type f)
	
	myDirGroupName=$(basename "$subDir")		
	echo "PRODESSING DIRECTORY GROUP: $myDirGroupName"
	
	getMunkiItemNames=$(for item in $getPkgsInfoFiles; do if defaults read "$item" update_for >/dev/null 2>&1 ; then continue; fi; defaults read "$item" name 2>/dev/null; done | sort -u )
	
	for munkiItem in $getMunkiItemNames
	do		
		if ! defaults read "$dirToCreateManifests/$myDirGroupName" managed_installs 2>&1 | grep -q -w -o "$munkiItem"
		then
			defaults write "$dirToCreateManifests/$myDirGroupName" managed_installs -array-add "$munkiItem"
		fi

		# add a catalog if needed
		if ! defaults read "$dirToCreateManifests/$myDirGroupName" catalogs 2>&1 | grep -q -w -o "$addCatalog"
		then
			defaults write "$dirToCreateManifests/$myDirGroupName" catalogs -array-add "$addCatalog"
		fi

		plutil -convert xml1 "$dirToCreateManifests/$myDirGroupName.plist"
		
		# needed if pkginfo needs no .plist ending
		# mv "$dirToCreateManifests/$myDirGroupName.plist" "$dirToCreateManifests/$myDirGroupName"
	done
done

# ensure that all users can at least read the results
chmod -R a+rX "$dirToCreateManifests"

echo "ALL DONE."

exit 0