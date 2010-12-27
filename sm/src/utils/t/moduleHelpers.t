# -*-sh-*-


export PERL5LIB=$(cd ${STUPID_SRC_DIR}/.. && pwd):$PERL5LIB

echo

env | egrep \(PERL5LIB\|STUPID\)

cd $STUPID_EXTRAS_DIR

./moduleHelpersTestChassis.pl


