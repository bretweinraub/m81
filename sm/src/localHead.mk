
makeDepend=$(wildcard make.depend)
ifneq ($(makeDepend),)
include make.depend
endif

ifneq ($(DEBUG),)
SHELL=/bin/bash -x 
endif

depend ::;	rm -f make.depend.new
		for suffix in $(sort $(patsubst %.m4,%,$(SUFFIXES))) ; do \
			echo making depend for $$suffix ; \
			for file in *$$suffix.m4 ; do \
				echo file is $$file ; \
				if [ -f $$file ]; then \
					thisfile=$$(echo $$file | cut -d. -f-2) ; \
					doit=true ; \
					all=$$all" "$$thisfile ; \
					echo all is $$all; \
				fi ; \
			done ; \
		done ; \
		if [ -n "$$doit" ]; then \
			echo "all default :: $$all" >> make.depend.new ; \
			for file in $$all ; do \
				echo "$$file : $$file.m4" >> make.depend.new ; \
			done ; \
		fi 
		@mv make.depend.new make.depend


%.dat : %.dat.m80
		runPath.pl $(DEBUGFLAG) -file $< 


realclean ::	clean
		rm -f *~

SUFFIXES	=	.pl .pl.m4 .pm .pm.m4 
%.pl : %.pl.m4 Makefile
	@export REQUIRED_VALUES=$$(awk '$$2 == "M80_VARIABLE" {print $$3}' < $<) ; \
        echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
        eval `varWarrior $$REQUIRED_VALUES` ; \
	if test -n "${VC_EDIT}" -a -z "${SUPPRESS_VC}"; then \
		${VC_EDIT} $@ ; \
	fi ; \
	echo $(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") $< \> $@ ; \
        if test -s $*.m4errors ; then \
           rm -f $*.m4errors ; \
        fi ; \
	eval $(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") $< 2> $*.m4errors > $@ ; \
        if test  $$? -ne 0 -o -s $*.m4errors ; then \
           echo m4 errors\; bailing out ; \
	   echo Errors from file $*.m4errors : ; \
           cat $*.m4errors ; \
           exit 1 ; \
        else  \
           rm -f $*.m4errors ; \
        fi ; \
	exit 0
plm4files	=	$(wildcard *.pl.m4)
derivedplfiles = 	$(plm4files:.pl.m4=.pl)
clean		::;	rm -f $(derivedplfiles)
%.pm : %.pm.m4 Makefile
	@export REQUIRED_VALUES=$$(awk '$$2 == "M80_VARIABLE" {print $$3}' < $<) ; \
        echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
        eval `varWarrior $$REQUIRED_VALUES` ; \
	if test -n "${VC_EDIT}" -a -z "${SUPPRESS_VC}"; then \
		${VC_EDIT} $@ ; \
	fi ; \
	echo $(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") $< \> $@ ; \
        if test -s $*.m4errors ; then \
           rm -f $*.m4errors ; \
        fi ; \
	eval $(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") $< 2> $*.m4errors > $@ ; \
        if test  $$? -ne 0 -o -s $*.m4errors ; then \
           echo m4 errors\; bailing out ; \
	   echo Errors from file $*.m4errors : ; \
           cat $*.m4errors ; \
           exit 1 ; \
        else  \
           rm -f $*.m4errors ; \
        fi ; \
	exit 0
pmm4files	=	$(wildcard *.pm.m4)
derivedpmfiles = 	$(pmm4files:.pm.m4=.pm)
clean		::;	rm -f $(derivedpmfiles)
m4command :; echo $(M4) $(M4_FLAGS)
#
# The following loads local make rules.  Use this local file
# for rules, as editing this file could cause your rules to be overwritten.
#

#
# The following code block does not work in a multi-depot environment.  When merging the branches
# we need to rectify this.
#


#generate_p4_headrevision ::
#	files=$$(cd $$CONTROLLER_deploy_PATH && p4 files ...) ; \
#	if test -n "$$files"; then \
#		(cd $$CONTROLLER_deploy_PATH && p4 changes -m 1 ... | cut -d' ' -f2) > $$CONTROLLER_deploy_PATH/.headrevision ; \
#	else \
#		printmsg no p4 data for this modules ... no manifest will be generated ; \
#	fi
#
#

all deploy	:: ContextExporter.pm
	(cd utils; make)
	(cd testMachine; make)

include ../../m81.mk


M80LIB=$(shell m80 --libpath)

pmm80files	= $(wildcard *.m80)
nopmm80files	= $(patsubst %.m80,%,$(pmm80files))

plm80files	= $(wildcard *.m80)
noplm80files	= $(patsubst %.m80,%,$(plm80files))

shm80files	= $(wildcard *.m80)
noshm80files	= $(patsubst %.m80,%,$(shm80files))

xmlm80files	= $(wildcard *.m80)
noxmlm80files	= $(patsubst %.m80,%,$(xmlm80files))

%.pm	:	%.pm.m80
	runPath.pl -file $< -dest $@

%.pl	:	%.pl.m80
	runPath.pl -file $< -dest $@

%.sh	:	%.sh.m80
	runPath.pl -file $< -dest $@

%.xml	:	%.xml.m80
	runPath.pl -file $< -dest $@

all ::  $(nopmm80files) $(noplm80files) $(noxmlm80files) $(noshm80files) 

clean ::; rm -f *~ *.bak $(nopmm80files) $(noplm80files) $(noxmlm80files) $(noshm80files)

#
# The following loads local make rules.  Use this local file
# for rules, as editing this file could cause your rules to be overwritten.
#

localTailRules=$(wildcard localTail.mk)
ifneq ($(localTailRules),)
include localTail.mk
endif



ScriptTemplates=$(wildcard *.pl.m80)
ScriptExes=$(ScriptTemplates:.pl.m80=.pl)
Scripts=$(ScriptExes:.pl=)

% : %.pl
	cp -p $< $@

all :: $(Scripts)

clean	::; rm -f $(Scripts)

test	::; echo $(Scripts)


