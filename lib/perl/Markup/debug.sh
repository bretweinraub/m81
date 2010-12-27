#!/bin/bash

eval $(m80 --genfuncs)

m80 --execute embedperl -du < Grid.pm.m80 | grep -i -v m80 > Grid.pm

m80 --execute perl -d:ptkdb Grid.pm

