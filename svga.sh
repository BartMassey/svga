#!/bin/sh
# Copyright © 2015 Bart Massey
# This code is available under the MIT license. Please see the
# file `COPYING` in this distribution for license terms.

# Set up projectors on a Linux box using xrandr.

TMP="/tmp/svga.$$"
trap "rm -f $TMP" 0 1 2 3 15

MODE=best
case $# in
1)
        MODE=$1
        ;;
esac

xrandr >$TMP
OUTPUTS="`egrep -v '^ ' $TMP | egrep -v '^Screen' | awk '
$2==\"connected\" {
  if ($3 == \"primary\")
     primary=$1
  else
     alt[++n]=$1
}
END {
  if (primary)
     print primary
  for (i in alt)
     print alt[i]
}'`"

for OUTPUT in $OUTPUTS
do
    echo "$OUTPUT"
done
exit 0

if [ "$1" = off ]
then
    EXTRA=false
    xrandr -s 0
    for OUTPUT in $OUTPUTS
    do
	$EXTRA && xrandr --output "$OUTPUT" --off
	EXTRA=true
    done
    exit 0
fi

exit 0

if [ OUTPUTS = '' ]
then
    echo "no extra outputs to enable" >&2
    exit 1
fi

xrandr -s "$MODE"
for OUTPUT in $OUTPUTS
do
    xrandr --output "$OUTPUT" --off --mode "$MODE"
done
