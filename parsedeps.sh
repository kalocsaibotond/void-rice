#!/bin/sh

deps=""
for argument in $@; do
  deps+="$(sed 's/#.*//g' $argument |
    sed -z 's/[ \r\n]\+/ /g') "
done
echo $deps
