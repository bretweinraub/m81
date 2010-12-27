#!/bin/bash

shell2context.pl -verbose <<EOF
export a="1"
EOF


shell2context.pl -verbose -task_id 1 <<EOF
export a="1"
EOF

