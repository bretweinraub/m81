#
#
# "dist" - really should be part of m80
#
#

binfiles	=	.headrevision *.pl *.pm utils/*.{pm,pl,sh,sql} *.dat startSM config
distname	=	StateMachine
majorVersion	=	0.03

# directories to build in
distdirs	=
linkdirs	=	logs

destUser	= $(CONTROLLER_DEPLOY_USER)
destHost	= $(CONTROLLER_DEPLOY_HOST)
destDir		= $(CONTROLLER_DEPLOY_DIR)

SUPPRESS_VC	=	true

%.m80	:	%.m80.m80
	runPath.pl -file $< -dest $@

%.sh	:	%.sh.m80
	runPath.pl -file $< -dest $@

%.pm	:	%.pm.m80
	runPath.pl -file $< -dest $@

deploy	::	clean crontab.dat startSM

clean	::;	rm -f startSM generatedConfig.xml

raws = $(wildcard *.raw)
profs = $(raws:.raw=.sort)

profiles : $(profs)

%.sort :: %.raw
	(cd utils ; ./Dprofpp.pl < ../$< > ../$@)

include	distRules.mk

