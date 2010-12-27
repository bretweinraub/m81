#
# m81shell.sh
#
#

echo "Loading m81shell.sh"

createUser () {
    m80 --execute runPath -fi $M81_HOME/sm/src/utils/createUser10g.m80
}


function reconfbdf () { rm -f $M80_REPOSITORY/bdfs/$M80_BDF.sh ; make -C $M80_REPOSITORY ; FORCE=t . $TOP/shelloader.sh ;  } 

export PERL5LIB=${PERL5LIB}:$M81_HOME/lib/perl
export PATH=${PATH}:$M81_HOME/New:$M81_HOME/bin:$M81_HOME/sm/src/utils

function showpaths () { m80 --dump | grep ^$*= | tr ":" "\n" ; }

function snap () { m80 --execute smtop.pl -r 0 -i $* ; }

function New () { m80 --execute New.pl $* ; }

EDITOR=${EDITOR:-emacs -nw}

function m81shell () { $EDITOR $M81_HOME/m81shell.sh ;  . $M81_HOME/m81shell.sh ; }

function tlogs () { 
    task_id=$1; shift;
    local BROWSER ; BROWSER=${BROWSER:-lynx} ;
    local HTDOCS ; HTDOCS=${HTDOCS=/var/www/html}
#    master_task_id=`m80 --execute getMasterTaskID.pl -task_id $task_id` ;
    master_task_id=$task_id
    if [ -f ${HTDOCS}/${M80_BDF}/taskData/$master_task_id.tar.gz ]; then
        if [ ! -d ${HTDOCS}/${M80_BDF}/taskData/$master_task_id ]; then
            mkdir ${HTDOCS}/${M80_BDF}/taskData/$master_task_id && cp ${HTDOCS}/${M80_BDF}/taskData/$master_task_id.tar.gz ${HTDOCS}/${M80_BDF}/taskData/$master_task_id ;
            (cd ${HTDOCS}/${M80_BDF}/taskData/$master_task_id && tar zxf $master_task_id.tar.gz ; ) ;
        fi ;
        mexec ${BROWSER} http://\${CONTROLLER_DEPLOY_HOST}/${M80_BDF}/taskData/$master_task_id/$task_id ;
    else
        mexec ${BROWSER} http://\${CONTROLLER_DEPLOY_HOST}/${M80_BDF}/taskData/$task_id ;
    fi ;
}

function rununder () { action_id=$1 ; shift ; COMMAND="$*" m80 --execute debugChassis.sh -a $action_id -c eval -s ; } ;

function dumpc () { m80 --execute dumpContext.pl -ta $* | sort; }

function GO () { cd $(m80 --execute echo \$$1_deploy_PATH) ; }

function editbdf () { $EDITOR $M80_REPOSITORY/bdfs/$M80_BDF.sh.m80 ; }

function smtop () { m80 --execute smtop.pl -$* ; }


function killtask () { mexec killTask.pl -ta $* ; }

function dp () { m80 --oldschool -t deploy -m $* ; }

function metadata { COMMAND='vim $collections' m80 --execute debugChassis.sh -t $1 -c eval -s ; }

