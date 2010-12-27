m4_define([addDatabase],[
# $0(NAME => $1, USER => $2, PASS => $3, SID => $4)
append_variable_space([DATABASES],[$1])
define_variable([$1_TYPE],[DATABASE])
define_variable([$1_THIS],[$1])
define_variable([$1_DATABASE_NAME],[$2/$3@$4])
])m4_dnl

m4_define([databaseUser],[
# $0(NAME => $1, USERNAME => $2, {PASSWORD => $3})
append_variable_space([DATABASE_USERS],[$1])
define_variable([$1_TYPE],[DATABASE_USER])
define_variable([$1_USERNAME],[$2])
m4_ifelse($3,,
define_variable([$1_PASSWORD],[$2]),
define_variable([$1_PASSWORD],[$3]))
])m4_dnl

# don't grant DBA to  this database on create
m4_define([restrictDBA],[
define_variable([$1_RESTRICTDBA],t)
])m4_dnl

m4_define([databaseModule],[
append_variable_space([DATABASE_MODULES],[$1])
m4_ifelse($4,,
m80NewCustomModule([$1],((patch,$2/src,make),(baseline,$2/baseline,make))),
m80NewCustomModule([$1],((patch,$4,make),(baseline,$4,make)))
)
define_variable([$1_THIS],[$1])
m4_ifelse($3,,,
define_variable([$1_DATABASE_NAME],m80var($3_DATABASE_NAME)))m4_dnl
])m4_dnl


m4_define([grantReadWriteFromTo],[
append_variable_space([$1_WRITERS],$2)
])m4_dnl

m4_define([grantReadOnFromTo],[
append_variable_space([$2_READERS],$3)
define_variable([$2_$3_READLIST],$1)
])m4_dnl
