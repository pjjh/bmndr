#!/bin/sh

if [ -z "$1" ] ; then
  echo "Usage: $(/usr/bin/basename $0) goal1 [goal2 ...]"
  echo "Increments each goal listed on the command line"
  exit
fi

for goal in "$@" 
do
  echo $goal:
  bmndr $goal 1
done

