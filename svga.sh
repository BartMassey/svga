#!/bin/sh
# Copyright © 2015 Bart Massey
# This code is available under the MIT license. Please see the
# file `COPYING` in this distribution for license terms.

# Set up projectors on a Linux box using xrandr.

TMP="/tmp/svga.$$"
trap "rm -f $TMP" 0 1 2 3 15

xrandr |
egrep -v '^Screen' |
awk '
  $0~/^ / {
    if (current)
       modes[current][++nmc] = $1
    next
  }
  $2=="connected" {
    if ($3 == "primary")
       primary = $1
    else
       alt[++nalt] = $1
    current = $1
  }
  END {
    if (primary) {
       for (i in modes[primary]) {
	   found_matches = 1
           for (j in alt) {
	       found_match = 0
               for (k in modes[alt[j]]) {
                   if (modes[alt[j]][k] == modes[primary][i]) {
		       found_match = 1
		       break
		   }
	       }
	       if (!found_match) {
		   found_matches = 0
		   break
	       }
           }
	   if (found_matches)
	       ok_modes[++nok_modes] = modes[primary][i]
       }
       if (nok_modes) {
	   best_pixels = 0
	   for (i in ok_modes) {
	       ndims = split(ok_modes[i], dims, "x")
	       if (ndims != 2)
		   continue
	       pixels = dims[1] * dims[2]
	       if (pixels == 0)
		   continue
	       if (pixels > best_pixels) {
		   best_pixels = pixels
		   best_mode = ok_modes[i]
	       }
	   }
	   if (best_mode) {
	       print best_mode
               print primary
	       for (i in alt)
		   print alt[i]
	   }
       }
    }
  }' >$TMP

if [ "`cat $TMP`" = "" ]
then
    echo "not enough information, giving up" >&2
    exit 1
fi

cat $TMP | (
  read MODE
  read PRIMARY

  if [ $# -eq 1 ]
  then
      MODE="$1"
  fi

  if [ "$MODE" = off ]
  then
      while read OUTPUT
      do
	  xrandr --output "$OUTPUT" --off
      done
      xrandr -s 0
      exit 0
  fi

  xrandr --output "$PRIMARY" --mode $MODE
  while read OUTPUT
  do
      xrandr --output "$OUTPUT" --off --mode "$MODE" --same-as "$PRIMARY"
  done
)
