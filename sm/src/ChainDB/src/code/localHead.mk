


PERL5LIB=$(M81_HOME)/lib/perl:$(M81_HOME)/sm/src/utils

.PHONY :test
test ::; env

m80files=$(wildcard *.m80)
m80dests=$(m80files=.m80=)
gen ::;  rm -f $(m80dests)
	for file in $(m80files); do \
		runPath -file $$file ; \
	done

patch :: gen



