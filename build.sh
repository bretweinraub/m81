#!/bin/bash

./configure.sh
export M81_HOME=$(pwd)
PERL5LIB=$(pwd)/lib/perl make -k

cat <<EOF

Build of m81 finished!

To complete, 
add to your profile:

export M81_HOME=$(pwd)
export PATH=\$PATH:$(pwd)/bin
export PERL5LIB=\$PERL5LIB:$(pwd)/lib/perl
EOF

