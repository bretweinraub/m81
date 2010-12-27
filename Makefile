# m80path=(embedperl.pl)
# this file was programtically generated by m80, edit it at your own risk.
#
# m80 was Built for CYGWIN_NT-5.1 by Administrator on bweinrau01, Sat Jan  8 16:28:13 MST 2005
# 
# Edits MAY be lost if this file is regenerated.
#
# The following line(s) is for internal use and should not be changed:
# CLISP (setq COMMAND "newModule"
# CLISP       ARGS '( "-m" "generic" "-t" "generic")
# CLISP       [0.07.00] 0.07.00)
#

M80LIB=$(shell m80 --libpath)

# The following loads local make rules.  Use this local file
# for rules, as editing this file could cause your rules to be overwritten.

localHeadRules=$(wildcard localHead.mk)
ifneq ($(localHeadRules),)
include localHead.mk
endif

ifneq ($(DEBUG),)
SHELL=/bin/bash -x 
endif

SUBDIRS = $(shell find . -type d -maxdepth 1 | cut -c3- | grep -v lib) 

default :: all


realclean ::	clean
		rm -f *~


clean realclean build all ::
	@for dir in lib $(SUBDIRS); do \
                if test -f $$dir/Makefile; then \
			$(MAKE) -C $$dir $@ ; \
			if [ $$? -ne 0 ]; then \
				exit 1 ; \
			fi ; \
                fi ; \
        done


include $(M80LIB)/make/m80loadenv.mk
include $(M80LIB)/make/local.mk
include $(M80LIB)/make/m80generic.mk


#
# No suffix rules defined.  If you find your .m80 files will not convert,
# try and use the -S flag to "m80 --newModule" to specify the suffix of the
# file.  An a good example is files with a ".sh" suffix, they require the 
# module be built:
#
#
# m80 --newModule -m {moduleName} -t {moduleType}-S "sh" 
#
# You can alternately use the SUFFIXES environment variable also.
#

pmm80files	= $(wildcard *.m80)
nopmm80files	= $(patsubst %.m80,%,$(pmm80files))

plm80files	= $(wildcard *.m80)
noplm80files	= $(patsubst %.m80,%,$(plm80files))

shm80files	= $(wildcard *.m80)
noshm80files	= $(patsubst %.m80,%,$(shm80files))

%.pm	:	%.pm.m80
	runPath.pl -file $< -dest $@

%.pl	:	%.pl.m80
	runPath.pl -file $< -dest $@

%.sh	:	%.sh.m80
	runPath.pl -file $< -dest $@

all ::  $(nopmm80files) $(noplm80files) $(noshm80files)

clean ::; rm -f *~ *.bak $(nopmm80files) $(noplm80files) $(noshm80files)

#
# The following loads local make rules.  Use this local file
# for rules, as editing this file could cause your rules to be overwritten.
#

localTailRules=$(wildcard localTail.mk)
ifneq ($(localTailRules),)
include localTail.mk
endif