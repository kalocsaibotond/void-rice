#!/bin/sh

deps=""
for argument in $@; do
  deps="${deps}$(
    sed -e 's/#[^\n]*/ /g' -e 'y/\n/ /' -e 's/[ \r]\+/ /g' $argument
  ) "
done
echo $deps
