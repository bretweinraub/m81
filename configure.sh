#!/bin/bash

path=$(pwd)

cat > m81.mk <<EOF

#
# autogenerated - do not edit
#

export M81_HOME=$path
export PERL5LIB=$path/lib/perl

EOF

cat > m81loader.sh <<EOF
. $path/m81shell.sh
export M81_HOME=$path
export PERL5LIB=$path/lib/perl


EOF




