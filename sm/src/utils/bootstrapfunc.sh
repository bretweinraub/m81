#!/bin/sh

# TITLE StateMachine Bootstrap Helper Functions

echo 'function bsp { tail -f /var/www/html/$M80_BDF/taskData/$1/*.smBootstrap_parent.* ; } ; ' 
echo 'function bsl { ls -al /var/www/html/$M80_BDF/taskData/$1 ; } ; '
