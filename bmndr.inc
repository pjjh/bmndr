#!/bin/sh

# USAGE: bmndr.inc goal [goal] [goal] ...
#        adds a +1 datapoint to each listed goal
#        Depends on lydgate's bmndr script
#
# AUTHOR:  Philip Hellyer, www.hellyer.net
# URL:     https://github.com/pjjh/bmndr
# FILE:    bmndr.inc
# LICENSE: Creative Commons BY-SA
#          http://creativecommons.org/licenses/by-sa/4.0/
#          Copyright 2015 Philip Hellyer

if [ -z "$1" ] ; then
  echo "Usage: $(/usr/bin/basename $0) [-m 'common comment'] goal1 [goal2 ...]"
  echo "Increments each goal listed on the command line"
  exit
fi

if [ '-m' == "$1" ] ; then
  shift
  COMMENT="$1"
  shift
fi

for goal in "$@" 
do
  echo $goal:
  bmndr $goal 1 "$COMMENT"
done

