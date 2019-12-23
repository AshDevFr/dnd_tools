#!/usr/bin/env bash

CWD=`pwd`
BASE_DIR="$1"
PACK_FILE="$BASE_DIR/pack.xml"

function kebab_case () {
  echo $1 | sed -e "s/ /-/" | tr '[:upper:]' '[:lower:]'
}

function process_dir () {
  pushd "$1"
  echo "process_dir $1"
  local dir="$1"
  local parent_base=$([ -n "$2" ] && echo -e "$2/" || echo "")
  local parent=$([ -n "$3" ] && echo -e " parent=\"$3\"" || echo "")
  local sort=1
  for file in "$dir"/*; do
    local ITEM_UUID=`uuidgen`
    if [ -d "$file" ]; then
      local group_name=`basename "$file"`
      local group_slug=`kebab_case "$group_name"`
      echo -e "\t<group id=\"$ITEM_UUID\" sort=\"$sort\"$parent>" >> "$PACK_FILE"
    	echo -e "\t\t<name>$group_name</name>" >> "$PACK_FILE"
    	echo -e "\t\t<slug>$group_slug</slug>" >> "$PACK_FILE"
    	echo -e "\t</group>" >> "$PACK_FILE"
      sort=`expr $sort + 1`
      process_dir "$file" "$parent_base$group_name" "$ITEM_UUID"
    elif [ -f "$file" ]; then
      local resource_bname=`basename "$file"`
    	local resource_name="${resource_bname%.*}"
    	if [ "${file##*.}" != ".xml" ]
    	then
    		echo -e "\t<asset id=\"${ITEM_UUID}\"$parent>" >> "$PACK_FILE"
    		echo -e "\t\t<name>${resource_name}</name>" >> "$PACK_FILE"
    		echo -e "\t\t<resource>$parent_base${resource_bname}</resource>" >> "$PACK_FILE"
    		echo -e "\t\t<type>image</type>" >> "$PACK_FILE"
    		echo -e "\t\t<size></size>" >> "$PACK_FILE"
    		echo -e "\t</asset>" >> "$PACK_FILE"
    	fi
    fi
  done
  popd
}


PACK=`basename "$BASE_DIR"`
SLUG=`kebab_case "$PACK"`
UUID=`uuidgen`
echo -e "Generating ${PACK}.pack"
echo -e "Generating ${PACK}.pack"

pushd "$1"

echo -e '<?xml version="1.0" encoding="utf-8" standalone="no"?>' > "$PACK_FILE"
echo -e "<pack id=\"${UUID}\">" >> "$PACK_FILE"
echo -e "\t<name>${PACK}</name>" >> "$PACK_FILE"
echo -e "\t<slug>${SLUG}</slug>" >> "$PACK_FILE"
echo -e "\t<description></description>" >> "$PACK_FILE"
echo -e "\t<author></author>" >> "$PACK_FILE"
echo -e "\t<code></code>" >> "$PACK_FILE"
echo -e "\t<category>personal</category>" >> "$PACK_FILE"
echo -e "\t<image></image>" >> "$PACK_FILE"

process_dir "$BASE_DIR"

echo -e "</pack>" >> "$PACK_FILE"
# zip "../${PACK}.zip" *.*
# pushd ..
# mv "${PACK}.zip" "${PACK}.pack"
# popd
popd
