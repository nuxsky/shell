#!/bin/bash
# v1.0.3

if [ $1 ]; then
  wget http://sh.nuxsky.com/$1.sh
  sh $1.sh ${@:2}
  rm -f $1.sh
  echo "$1.sh ${@:2}" >> install.log
fi