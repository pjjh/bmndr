#!/bin/bash

# USAGE:   tmin.sh
#          Changes the tmin of specified
#          Depends on the bmndrrc file for $auth_token and $username
#          I use this to set different horizons for goals with different frequencies
#
# AUTHOR:  Philip Hellyer, www.hellyer.net
# URL:     https://github.com/pjjh/bmndr
# FILE:    tmin.sh
# LICENSE: Creative Commons BY-NC-SA
#          http://creativecommons.org/licenses/by-nc-sa/4.0/
#          Copyright 2017 Philip Hellyer

. ~/.bmndrrc


# Goal lists
#ALL_GOALS="$( curl -# https://www.beeminder.com//api/v1/users/$username.json?auth_token=$auth_token | sed -e 's/[^[]*//; s/^.//; s/].*//; s/[",]/ /g' )"
FREQUENT_GOALS='timelog earned'
DAILY_GOALS='cloze flex frauth dailies pitch contact units'
WEEKLY_GOALS='chicken timesum cpe gym gtd rfi reading reading-french hs-5di hs-bmndr hs-rwci drink beethere w checkin casestudy linkedin'
MONTHLY_GOALS='mum groundhog profdev emailzero gmailzero stringle'
DATA_GOALS='bmndr callback foursquare lola omnifocus nwo pomodoros rqzero testtweets tocks'
YEAR_EACH_WAY='exprd'


# Date deltas
FORTNIGHT=$(date -v-2w +%Y-%m-%d)
MONTH=$(    date -v-1m +%Y-%m-%d)
QUARTER=$(  date -v-3m +%Y-%m-%d)
YEAR=$(     date -v-1y +%Y-%m-%d)
NEXTYEAR=$( date -v+1y +%Y-%m-%d)
DEFAULT=$QUARTER


echo 'Frequent Goals'
for GOAL in $FREQUENT_GOALS
do
  echo $GOAL
  TMIN=$FORTNIGHT
  curl -# -X PUT -d "{\"tmin\":\"$TMIN\"}" https://www.beeminder.com/api/v1/users/$username/goals/$GOAL.json?auth_token=$auth_token --header "Content-Type: application/json" > /dev/null
done

echo 'Daily Goals'
for GOAL in $DAILY_GOALS
do
  echo $GOAL
  TMIN=$MONTH
  curl -# -X PUT -d "{\"tmin\":\"$TMIN\"}" https://www.beeminder.com/api/v1/users/$username/goals/$GOAL.json?auth_token=$auth_token --header "Content-Type: application/json" > /dev/null
done

echo 'Weekly Goals'
for GOAL in $WEEKLY_GOALS
do
  echo $GOAL
  TMIN=$QUARTER
  curl -# -X PUT -d "{\"tmin\":\"$TMIN\"}" https://www.beeminder.com/api/v1/users/$username/goals/$GOAL.json?auth_token=$auth_token --header "Content-Type: application/json" > /dev/null
done

echo 'Monthly Goals'
for GOAL in $MONTHLY_GOALS $DATA_GOALS
do
  echo $GOAL
  TMIN=$YEAR
  curl -# -X PUT -d "{\"tmin\":\"$TMIN\"}" https://www.beeminder.com/api/v1/users/$username/goals/$GOAL.json?auth_token=$auth_token --header "Content-Type: application/json" > /dev/null
done

echo 'Yearly Goals'
# also sets tmax!
for GOAL in $YEAR_EACH_WAY
do
  echo $GOAL
  curl -# -X PUT -d "{\"tmax\":\"$NEXTYEAR\", \"tmin\":\"$YEAR\"}" https://www.beeminder.com/api/v1/users/$username/goals/$GOAL.json?auth_token=$auth_token --header "Content-Type: application/json" > /dev/null
done

