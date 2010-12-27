#-*-sh-*-

root=`dirname $0`/`basename $0 .t`
cd $root

#
# The first test should fail. This is trapped
# and tested for. If it failed, the script will
# continue
#
cat > ./test.sh.m80 <<'EOF'
<:
use shellHelpers; # $m80path = [{command => "embedperl.pl"}, {command => "m4", chmod => "+x" }]; 


print shellHelpers::genAndPushDOSTemplate ( requiredVars => [],
					    templateName => 'LRtestscript.vbs.m80',
					    destination => '/tmp/$0.$RANDOM/');  :>


EOF

runPath --file test.sh.m80

res=$?
if test $res -ne 0; then
    echo "shell helpers library is generating different code stuctures now"
    exit 10
fi

diff ./test.sh cache
exit $?




