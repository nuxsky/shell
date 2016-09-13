#!/bin/sh

md5=$(echo -n $1 | md5sum | cut -d ' ' -f1)
str=${md5:0:8}${1}'Adminn_cnd3d3LmFkbWlubi5jbnNob3VxdWFubWE=d3d3LmFkbWlubi5jbnNob3VxdWFubWE=d3d3LmFkbWlubi5jbnNob3VxdWFubWE='
str2=$(echo -n $str | md5sum | cut -d ' ' -f1)
echo -n $str2 | md5sum | cut -d ' ' -f1