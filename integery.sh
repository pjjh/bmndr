#!/bin/sh


if [ -z "$1" -o '--help' == "$1" ] ; then
  echo "Usage: $0 goal"
  echo "    changes goal to integery"
  exit 1
fi


# should be in ~/.bmndrrc
username=''
auth_token=''

if [ -e ~/.bmndrrc ] ; then
  echo > .$$.rc
  grep 'username='   ~/.bmndrrc >> .$$.rc
  grep 'auth_token=' ~/.bmndrrc >> .$$.rc
  . .$$.rc
  rm .$$.rc
fi

if [ -z "$username" -o -z "$auth_token" ] ; then
  echo "ERROR: missing username or auth_token"
  exit 1
fi

curl  -H "Content-Type: application/json" -X PUT -d '{"integery":"true"}' https://www.beeminder.com/api/v1/users/$username/goals/$1.json?auth_token=$auth_token

