#!/usr/bin/sh
# Recursively find if libraries are missing for Android binaries.
# NOTE: This script does not find missing symbols, it only shows missing libraries.
FOUNDLIBS=""
MISSINGLIBS=""
SYMLINKLIBS=""

getlibs () {
	readelf -d $1 | grep '(NEEDED).*Shared library:' | awk -F'[\\[\\]]' '{print $2}'
}

checkfile () {
	if [ -h $1 ]; then
		echo $SYMLINKLIBS | grep -q $1 ||
		SYMLINKLIBS="$SYMLINKLIBS $1"
	else
		ls $1 2> /dev/null &&
		FOUNDLIBS="$FOUNDLIBS $1"
	fi
}

checklibs () {
	LIBRARIES=$(getlibs $1)
	for i in $LIBRARIES; do
		checkfile system/lib64/$i ||
		checkfile system/lib64/hw/$i ||
		checkfile system/system/lib64/$i ||
		checkfile system/system/lib64/hw/$i ||
		checkfile vendor/lib64/$i ||
		checkfile vendor/lib64/hw/$i ||
		echo $MISSINGLIBS | grep -q $i ||
		MISSINGLIBS="$MISSINGLIBS $i"
	done
}

if [ ! -e $1 ]; then
	echo -e "\033[0;91mERROR:\033[0m File not found"
	exit 127
fi

echo "Found libraries:"
checklibs $1

if [ -n "$FOUNDLIBS" ]; then
	for j in $FOUNDLIBS; do
		checklibs $j
	done
fi

if [ -n "$MISSINGLIBS" ]; then
	echo -e "\n\033[0;93mMissing libraries:"
	for i in $MISSINGLIBS; do
		echo $i
	done
	echo -en "\033[0m"
fi

if [ -n "$SYMLINKLIBS" ]; then
	echo -e "\n\033[0;35mSymlink libraries:"
	for i in $SYMLINKLIBS; do
		ls -l $i | awk '{for (i=9; i<NF; i++) printf $i " "; print $NF}'
	done
	echo -en "\033[0m"
fi
