#!/bin/bash

./configure.sh
PERL5LIB=$(pwd)/lib/perl make -k

cat <<EOF

Build of m81 finished!

To complete, 
add to your profile:

export M81_HOME=$(pwd)
export PATH=\$PATH:$(pwd)/bin
EOF

