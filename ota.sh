#!/bin/bash

baseurl="https://mirror.codebucket.de/claymore1297/AICP/"

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

version=$(cut -d '-' -f2 <<<"$filename")
romtype=$(cut -d '-' -f4 <<<"$filename")
target=$(cut -d '-' -f5 <<<"${filename%.*}")

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

url=${baseurl%%/}/$version/$target/$filename

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
      "version": "$version"
    }
  ]
}
EOF

echo "Wrote data into \"${target}.json\""
