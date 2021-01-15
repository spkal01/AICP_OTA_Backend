#!/bin/bash

baseurl="http://files.spkal01.tech/Aicp/latest"

if [ "$1" == "" ]; then
	>&2 echo "Usage: $0 <filename> [<baseurl>]"
	exit 1
fi

if [ "$2" != "" ]; then
	baseurl=$2
fi

file=$1
filename=$(basename "$file")

if [ ! -e "$file" ]; then
	>&2 echo File \"$file\" not found
	exit 1
fi

version_raw=$(cut -d '_' -f3 <<<"$filename")
version=$(cut -d '-' -f1,2 <<<"$version_raw")
version_number=$(cut -d '-' -f 2 <<<"$version_raw")
romtype=$(cut -d '-' -f3 <<<"$filename")
target=$(cut -d '_' -f2 <<<"${filename%.*}")

id=$(md5sum "$file" | awk '{ print $1 }')
size=$(stat -c %s "$file")

if [ -e "${file}.md5sum" ]; then
	checkid=$(cat "${file}.md5sum" | awk '{ print $1 }')
	if [ "$id" != "$checkid" ]; then
		>&2 echo Found \"${file}.md5sum\", but checksum doesn\'t match
		>&2 echo "Calculated MD5: $id"
		>&2 echo "Original MD5:   $checkid"
		exit 1
	fi
else
	>&2 echo Warning: \"${file}.md5sum\" not found, not verifying checksum
fi

datetime=$(unzip -p "$file" META-INF/com/android/metadata | grep post-timestamp | cut -d= -f2)

url=${baseurl%%/}/$filename

cat << EOF | tee "${target}.json"
{
  "response": [
    {
      "datetime": "$datetime",
      "filename": "$filename",
      "id": "$id",
      "romtype": "$romtype",
      "size": "$size",
      "url": "$url",
      "version": "$version",
      "changelog_link": "http://files.spkal01.tech/Aicp/latest/Changelog.txt",
    }
  ]
}
EOF

echo "Wrote data into \"${target}.json\""
