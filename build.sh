#!/bin/bash

./configure.sh
. ./m81loader.sh

make -k

cat <<EOF

Build of m81 finished!

To complete, (and if the build above looks successfull)
add to your profile:

. $(pwd)/m81loader.sh # this will rig your environment to use this build of m81
EOF

