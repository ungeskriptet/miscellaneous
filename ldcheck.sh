#!/usr/bin/bash
FOUNDLIBS=""
MISSINGLIBS=""

getlibs () {
	readelf -d $1 | grep '(NEEDED).*Shared library:' | awk -F'[\[\]]' '{print $2}'
}

checkfile () {
	ls $1 2> /dev/null &&
	FOUNDLIBS="$FOUNDLIBS $1"
}

checklibs () {
	LIBRARIES=$(getlibs $1)
	for i in $LIBRARIES; do
		checkfile system/lib64/$i ||
		checkfile system/system/lib64/$i ||
		checkfile vendor/lib64/$i ||
		echo $MISSINGLIBS | grep -q $i ||
		MISSINGLIBS="$MISSINGLIBS $i"
	done
}

if [ ! -e $1 ]; then
	echo -e "\033[0;91mERROR:\033[0m File not found"
	exit 127
fi

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
