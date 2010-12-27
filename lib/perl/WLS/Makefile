# -*-makefile-*-
# $m80path = [{ command => 'embedperl' }]

localHeadRules=$(wildcard localHead.mk)
ifneq ($(localHeadRules),)
include localHead.mk
endif

export M4DEBUG	+=	 classWrapper.m4


pmm80files	= $(wildcard *.m80)
nopmm80files	= $(patsubst %.m80,%,$(pmm80files))

plm80files	= $(wildcard *.m80)
noplm80files	= $(patsubst %.m80,%,$(plm80files))


%.pm	:	%.pm.m80
	runPath.pl -file $< -dest $@

%.pl	:	%.pl.m80
	runPath.pl -file $< -dest $@


all ::  $(nopmm80files) 

clean ::; rm -f *~ *.bak $(nopmm80files) 

localTailRules=$(wildcard localTail.mk)
ifneq ($(localTailRules),)
include localTail.mk
endif
