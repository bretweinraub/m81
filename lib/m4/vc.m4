m4_define([svn_repo],[
#
# $0(
#	REPOS_LOGICAL_NAME	=> $1, 
#	SVN_REPO_URL		=> $2)
#

append_variable_space([SVN_REPOS],[$1])
define_variable($1_TYPE,SVN_REPO)
define_variable($1_REPO_URL,$2)
])m4_dnl

m4_define([svn_wc],[
#
# $0(
#	WORKING_COPY_LOGICAL_NAME	=> $1, 
#	WORKING_COPY_REPO		=> $2,
#	WORKING_COPY_HOST		=> $3,
#	WORKING_COPY_ROOT		=> $4)
#

append_variable_space([SVN_WCS],[$1])
define_variable($1_TYPE,SVN_WC)
define_variable($1_REPO,$2)
define_variable($1_HOST,$3)
define_variable($1_ROOT,$4)
])m4_dnl


m4_define([p4depot],[
#
# $0(
#	DEPOT_LOGICAL_NAME	=> $1, 
#	P4PORT			=> $2)
#

append_variable_space([P4_DEPOTS],[$1])
define_variable($1_TYPE,P4_DEPOT)
define_variable($1_P4PORT,$2)
])m4_dnl


m4_define([p4client],[
#
# $0(
#      	CLIENT_LOGICAL_NAME 	=> $1,
#	DEPOT 			=> $2,
#	P4CLIENT		=> $3,
#	P4USER			=> $4,
#	P4PASSWD		=> $5,
#       ROOT			=> $6,
#	{HOST			=> $7})
#
append_variable_space([P4_CLIENTS],[$1])
define_variable($1_TYPE,P4_CLIENT)
define_variable($1_DEPOT,$2)
define_variable($1_P4PORT,m80var($2_P4PORT))
define_variable($1_P4CLIENT,$3)
define_variable($1_P4USER,$4)
define_variable($1_P4PASSWD,$5)
define_variable($1_ROOT,$6)
define_variable($1_HOST,$7)
])m4_dnl

m4_define([p4branch],[
#
# $0(
#      	BRANCH_LOGICAL_NAME 	=> 	$1,
#	CLIENT_LOGICAL_NAME 	=> 	$2,
#	MAP 			=>	$3,
#	TARGETGROUP 		=>	$4)
#
append_variable_space([P4_BRANCHES],[$1])
define_variable($1_TYPE,P4_BRANCH)
define_variable($1_THIS,$1)
define_variable($1_CLIENT,$2)
define_variable($1_DEPOT,m80var($2_DEPOT))
define_variable($1_P4PORT,m80var($2_P4PORT))
define_variable($1_P4CLIENT,m80var($2_P4CLIENT))
define_variable($1_P4USER,m80var($2_P4USER))
define_variable($1_P4PASSWD,m80var($2_P4PASSWD))
define_variable($1_HOST,m80var($2_HOST))
define_variable($1_ROOT,m80var($2_ROOT))
define_variable($1_MAP,m80var($2_ROOT)/$3)
define_variable($1_TARGETGROUP,$4)
define_variable($1_THIS,$1)
m80NewCustomModule([$1],(($4[]sync,m80var($1_MAP),p4 sync ...,true),($4[]env,m80var($1_MAP),env),($4[]info,m80var($1_MAP),p4),($4[]submit,m80var($1_MAP),[p4 submit ...],true),($4[]opened,m80var($1_MAP),p4 opened ...,true),($4[]labelsync,m80var($1_MAP),labelsync.sh,true),($4[]changes,m80var($1_MAP),[p4 changes -m1 ...],true)))
])m4_dnl












