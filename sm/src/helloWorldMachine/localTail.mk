#
#
# "dist" - really should be part of m80
#
#

binfiles	=	*.m80 *.xml *.jar
distname	=	HelloWorld
majorVersion	=	0.01

# directories to build in
distdirs	=
linkdirs	=	logs

SUPPRESS_VC	=	true

include	../../distRules.mk
