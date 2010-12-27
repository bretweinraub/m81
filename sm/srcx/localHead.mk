
ScriptTemplates=$(wildcard *.pl.m80)
ScriptExes=$(ScriptTemplates:.pl.m80=.pl)
Scripts=$(ScriptExes:.pl=)

% : %.pl
	cp -p $< $@

all :: $(Scripts)

clean	::; rm -f $(Scripts)

test	::; echo $(Scripts)


