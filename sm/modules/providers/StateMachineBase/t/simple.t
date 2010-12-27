#!/bin/bash

export AUTOMATOR_STAGE_DIR=$(pwd)
export m81perlLib_DEPLOY_DIR=$M81_HOME/lib/perl/Metadata/Object

${STUPID_SRC_DIR}/../LoadMetadata.pl  -noappend -task_id 1 -force






