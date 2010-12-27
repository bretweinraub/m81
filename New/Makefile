# -*-makefile-*-
# $m80path = [{ command => 'embedperl' }]

localHeadRules=$(wildcard localHead.mk)
ifneq ($(localHeadRules),)
include localHead.mk
endif

ifeq ($(NO_M4_IMPORTS),)

endif

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

localTailRules=$(wildcard localTail.mk)
ifneq ($(localTailRules),)
include localTail.mk
endif
