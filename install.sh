#!/bin/bash
# v1.0.0

site=http://nuxsky.com

if [ ! $1 ]; then
  wget $site/$1.sh
  sh $1.sh $2
  rm -f $1.sh
  echo "$1 Has been installed" >> install.log
fi