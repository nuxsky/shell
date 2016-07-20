#!/bin/bash
# v1.0.2

site=http://sh.nuxsky.com

if [ $1 ]; then
  wget $site/$1.sh
  sh $1.sh $2
  rm -f $1.sh
  echo "$1.sh $2 has been performed successfully!" >> install.log
fi