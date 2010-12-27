#!/bin/bash

eval $(m80 --genfuncs)

m80 --execute embedperl -du < $1.m80 | grep -i -v m80 > $1

m80 --execute perl -d:ptkdb $1

