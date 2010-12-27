m4_divert(-1)
#
#


# {{{ Automator Macros ...

m4_define([newAutomator],[
# $0(NAME => $1, SID => $2, HOST => $3, PORT => $4, USER => $5, PASSWD => $6, DEPLOY_HOST => $7, DEPLOY_USER => $8, DEPLOY_BASE => $9, SRC_DIR => $10,  {DEPLOY_DIST_NAME =>$11}, SPAM_ADDRESS => $12, APACHE_PATH => 13 )
append_variable_space([AUTOMATORS],[$1])
define_variable([$1_TYPE],[AUTOMATOR])
define_variable([$1_SID],[$2])
define_variable([$1_type],[oracle])   # hard coded to oracle for now TODO: change this for portable automator
define_variable([$1_HOST],[$3])
define_variable([$1_PORT],[$4])
define_variable([$1_USER],[$5])
define_variable([$1_PASSWD],[$6])
define_variable([$1_DEPLOY_HOST],[$7])
define_variable([$1_DEPLOY_USER],[$8])
define_variable([$1_DEPLOY_BASE],[$9])
define_variable([$1_SRC_DIR],[$10])
m4_ifelse($11,,
define_variable([$1_DEPLOY_DIR],[$9/$10]),
define_variable([$1_DEPLOY_DIR],[$9/$11])
databaseModule([ChainDB],[$10/ChainDB])
m80NewCustomModule([$1],((deploy,$10,make),(clean,$10,make),(start,m80var($1_DEPLOY_DIR),./startSM),(env,$10,env,x)))
)
define_variable([$1_SPAM_ADDRESS],[$12])
m4_ifelse($13,,
define_variable([$1_APACHE_HOME],/var/www/html),
define_variable([$1_APACHE_HOME],[$13])
)
m4_ifelse($14,,
define_variable([$1_APACHE_CGIPORT],80),
define_variable([$1_APACHE_CGIPORT],[$14])
)
m4_dnl
m4_dnl Really this DB_THIS stuff needs to get pulled into a DatabaseModule Macro.
m4_dnl

addDatabase([$1_DB],$5,$6,$2)
m4_dnl define_variable([$1_DB_THIS],[$1_DB])
m4_dnl define_variable([$1_DB_DATABASE_NAME],[$5/$6@$2])
# append State Machine Directory to PERL5LIB
m4_ifelse(13,,
append_variable(PERL5LIB,":"m80var($1[]_DEPLOY_DIR))
append_variable(PERL5LIB,":"m80var($1[]_SRC_DIR)),
append_variable(PERL5LIB,":"m80var($1[]_SRC_DIR)))
append_variable(PERL5LIB,":"m80var($1[]_DEPLOY_DIR))
m4_dnl # 
])m4_dnl
# }}} end Automator Macros


# {{{ Automator Module Macros ...

m4_define([newDevelopmentAutomatorModule],[
# $0(NAME => $1, SRC_DIR => $2)
append_variable_space([AUTOMODULES],[$1])
define_variable([$1_TYPE],[AUTOMODULE])
define_variable([$1_DEPLOY_DIR],[$2])

define_variable([$1_SRC_DIR],[$2])
define_variable([$1_COMMAND_PROTOTYPE],[$3])
m80NewCustomModule([$1],((test,$2,smTestChassis.sh,true),(find,$2,find $(pwd)/.,true),(eval,$2,eval,true),(crondep,$2,smScheduler.sh,true)))
m4_dnl # 
])m4_dnl


m4_define([_newAutomatorModule],[
# $0(NAME => $1 ,DEPLOY_HOST => $2,DEPLOY_USER => $3,DEPLOY_DIR => $4, SRC_DIR => $5, {DEPLOY_DIST_NAME =>$6} )
append_variable_space([AUTOMODULES],[$1])
define_variable([$1_TYPE],[AUTOMODULE])
define_variable([$1_DEPLOY_HOST],[$2])
define_variable([$1_DEPLOY_USER],[$3])
define_variable([$1_DEPLOY_BASE],[$4])
m4_ifelse($6,,
define_variable([$1_DEPLOY_DIR],[$4/$5]),
define_variable([$1_DEPLOY_DIR],[$4/$6]))
define_variable([$1_SRC_DIR],[$5])
# define_variable([$1_ACTION_PROTOTYPE],[$7])
define_variable([$1_THIS],[$1])
# m80NewCustomModule([$1],((test,$5,smTestChassis.sh,true),(eval,$5,eval,true),(deploy,$5,smDeployer.sh),(crondep,$5,smScheduler.sh,true)))
m80NewCustomModule([$1],((deploy,$5,smDeployer.sh)))
m4_dnl # m80NewCustomModule([$1],((build,$5,make))) -- have to explicitly set this with (probably) the addOnControllerModule() syntax.
m4_dnl # 
m4_ifelse(m4_env(DEV),,
append_variable(PATH,":"m80var($1[]_DEPLOY_DIR))
,
append_variable(PATH,":"m80var($1[]_deploy_PATH))
append_variable(PATH,":"m80var($1[]_DEPLOY_DIR))
)
])m4_dnl

m4_define([newAutomatorModule],[
# $0(NAME => $1 , AUTOMATOR_NAME => $2, SRC_DIR => $3, DEPLOY_DIST_NAME =>$6)
_newAutomatorModule($1,m80var($2[]_DEPLOY_HOST),m80var($2[]_DEPLOY_USER),m80var($2[]_DEPLOY_BASE),$3,$4,$5)
])m4_dnl

# }}} end Automator Module Macros


# {{{ Other Macros
m4_define([directoryResource],[
append_variable_space([DIR_RESOURCES],[$1])
define_variable([$1_TYPE],[DIRECTORY_RESOURCE])
define_variable([$1_HOST],[$2])
define_variable([$1_USER],[$3])
define_variable([$1_DIR],[$4])
])

m4_define([addOnControllerModule],[
# $0 ( NAME => $1, CONTROLLER => $2, DIST_NAME => $3, TARGET_LIST => $4, APPEND_TO_PATH => $5)
append_variable_space([ADDONCONTROLLER_MODULES],[$1])
define_variable([$1_TYPE],[ADDONCONTROLLER_MODULE])
define_variable([$1_THIS],[$1])
define_variable([$1_DEPLOY_USER],m80var($2[]_DEPLOY_USER))
define_variable([$1_DEPLOY_HOST],m80var($2[]_DEPLOY_HOST))
define_variable([$1_DEPLOY_DIR],m80var($2[]_DEPLOY_BASE)/$3)
m80NewCustomModule([$1],$4)
m4_ifelse(m4_env(DEV),,
m4_ifelse($5,,,
append_variable(PATH,":"m80var($1[]_DEPLOY_DIR))
m4_dnl append_variable(PATH,":"m80var($1[]_deploy_PATH)) -- this shouldn't get set in production mode.
)
m4_ifelse($5,,,
append_variable(PERL5LIB,":"m80var($1[]_DEPLOY_DIR))
m4_dnl append_variable(PERL5LIB,":"m80var($1[]_deploy_PATH)) -- this shouldn't get set in production mode.
)
,
m4_ifelse($5,,,
append_variable(PATH,":"m80var($1[]_deploy_PATH))
append_variable(PATH,":"m80var($1[]_DEPLOY_DIR))
)
m4_ifelse($5,,,
append_variable(PERL5LIB,":"m80var($1[]_deploy_PATH))
append_variable(PERL5LIB,":"m80var($1[]_DEPLOY_DIR))
)
)
m4_dnl #
m4_dnl # If we are on the build box .... then we want the "source" path.  This is kind of an ugly solution
m4_dnl # for this; the PATH should get conditionally built based on the machine we are on.
m4_dnl #
m4_dnl append_variable(PATH,":"m80var($1[]_deploy_PATH)) -- this looks dated 
])m4_dnl

m4_define([deployableModule],[
# $0 ( NAME => $1, DEPLOY_USER => $2, DEPLOY_HOST => $3, DEPLOY_DIR => $4, DIST_NAME => $5, TARGET_LIST => $6)
append_variable_space([DEPLOYABLE_MODULES],[$1])
define_variable([$1_TYPE],[DEPLOYABLE_MODULE])
define_variable([$1_THIS],[$1])
define_variable([$1_DEPLOY_USER],$2)
define_variable([$1_DEPLOY_HOST],$3)
define_variable([$1_DEPLOY_DIR],$4/$5)
m80NewCustomModule([$1],$6)
])m4_dnl

m4_define(newDatabaseModule],[])
# }}} End Other Macros

m4_divert
