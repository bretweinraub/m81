fulldist	=	$(distname)-$(majorVersion).$(distnum)

destUser	= $(CONTROLLER_DEPLOY_USER)
destHost	= $(CONTROLLER_DEPLOY_HOST)
destDir		= $(CONTROLLER_DEPLOY_BASE)

distnum		= 	1

debug-dist	:; echo $(binfiles)

$(fulldist).tar.gz dist:	cleandist all   # validateEnv
		@mkdir -p $(fulldist) ; \
		if [ -n "$(distdirs)" ]; then \
			set $(distdirs) ; \
			while [ $$# -gt 0 ]; do \
			    newdir=$(fulldist)/$$1 ; \
			    test ! -d $$newdir && {  \
				mkdir -p $$newdir ; \
			    } ; \
			    shift ; \
			done ; \
		fi ; \
		if [ -n "$(linkdirs)" ]; then \
			set $(linkdirs) ; \
			while [ $$# -gt 0 ]; do \
			    (cd $(fulldist) ; ln -s ../$(distname).perm/$$1 $$1) ; \
			    shift ; \
			done ; \
		fi ; \
		tar cpvf - $(binfiles) $(configfile) | (cd $(fulldist) && tar xpvf -) ; \
		tar zcvf $(fulldist).tar.gz $(fulldist) && { echo "Joy ... dist left in "$(fulldist)".tar.gz" ; }
		rm -f latest.tar.gz
		ln -s $(fulldist).tar.gz latest.tar.gz

cleandist	:;	rm -rf $(fulldist) $(fulldist).tar.gz



deployCmd	= ssh $(SSH_EXTRAS) -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey -l $(destUser) $(destHost)

deploy ::	all $(fulldist).tar.gz
		$(MAKE) -C config
		$(deployCmd) 'mkdir -p $(destDir)' 
		if [ -n "$(linkdirs)" ]; then \
			set $(linkdirs) ; \
			while [ $$# -gt 0 ]; do \
			    echo $(deployCmd) 'mkdir -p $(destDir)/$(distname).perm/'$$1 ; \
			    $(deployCmd) 'mkdir -p $(destDir)/$(distname).perm/'$$1 ; \
			    shift ; \
			done ; \
		fi
		cat $(fulldist).tar.gz | $(deployCmd) '(cd $(destDir) ; tar zxvpf - ; rm -f $(distname) ; ln -s $(fulldist) $(distname))'
