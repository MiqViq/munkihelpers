#!/bin/bash

# create_munki_single_item_install_manifests.sh

# create single item manifests from all Munki items that are not update_for

echo "CREATING SINGLE-ITEM INSTALL MANIFESTS FOR MUNKI..."

munkiRepoDir="/path/to/munki/repo"

scanDir="$munkiRepoDir/pkgsinfo"

dirToCreateManifests="$HOME/Desktop/munki_single_item_install_manifests"

addCatalog=REQUIRED_CATALOG_NAME

mkdir -p -m 0777 "$dirToCreateManifests"

IFS=$'\n'

getPkgsInfoFiles=$(find "$scanDir" -type f) # use additional egrep -v (|) here to skip unwanted items

echo "COLLECTING MUNKI-ITEM-NAMES..."

getMunkiItemNames=$(for item in $getPkgsInfoFiles; do if defaults read "$item" update_for >/dev/null 2>&1 ; then continue; fi; defaults read "$item" name 2>/dev/null; done | sort -u )

for munkiItem in $getMunkiItemNames
do
	echo "PRODESSING MUNKI-ITEM: $munkiItem"

	if ! defaults read "$dirToCreateManifests/$munkiItem" managed_installs 2>/dev/null | grep -q -w -o "$munkiItem"
	then
		defaults write "$dirToCreateManifests/$munkiItem" managed_installs -array-add "$munkiItem"
	fi

	# add a catalog if needed
	if ! defaults read "$dirToCreateManifests/$munkiItem" catalogs 2>/dev/null | grep -q -w -o "$addCatalog"
	then
		defaults write "$dirToCreateManifests/$munkiItem" catalogs -array-add "$addCatalog"
	fi
	
	plutil -convert xml1 "$dirToCreateManifests/$munkiItem.plist"
	
	# needed if pkginfo needs no .plist ending
	# mv "$dirToCreateManifests/$munkiItem.plist" "$dirToCreateManifests/$munkiItem"
done

# ensure that all users can at least read the results
chmod -R a+rX "$dirToCreateManifests"

echo "ALL DONE."

exit 0