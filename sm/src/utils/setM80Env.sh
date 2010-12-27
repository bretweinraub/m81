#!/bin/echo You must execute this using: .
export M80_DIRECTORY=/home/jbaker/m80directory
export PATH=$PATH:/usr/local/m80-0.07/bin:/usr/local/oracle/product/10.1.0/client_1/bin
function m80chooser { eval $(m80 --chooser);} ; function m80cd { cd $(m80 --execute echo \$$1) ; } ; function m80directory { eval $(m80 --directory) ; } ; function mos { m80 --oldschool -t $* ; } ; function mexec { m80 --execute $* ; }
m80 --genfuncs
echo ""
echo ""
echo "choose your m80 directory:"
m80directory
echo ""
echo "Choose your m80 repository: (use #10 for SI test execution)"
eval $(m80 --chooser)
