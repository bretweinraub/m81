fulldist	=	$(distname)-$(majorVersion).$(distnum)

destUser	= $(CONTROLLER_DEPLOY_USER)
destHost	= $(CONTROLLER_DEPLOY_HOST)
destDir		= $(CONTROLLER_DEPLOY_BASE)

#ifeq ($(distnum),)
#distnum		:=	$(shell p4 changes -m 1 -s submitted ... | awk '{print $$2}')
#endif

distnum		= 	1

#validateEnv	:;	@if [ -z "$${perfDepot_P4_MAP}" ]; then \
#				echo "(m80) Environment variable perfDepot_P4_MAP must be set (and point to the top of the perf etl source tree)" ; \
#				exit 1 ; \
#			fi
#
#VERSION_INFO_PROCESSOR = $(perfDepot_P4_MAP)/util/p4Info2Env.pl

$(fulldist).tar.gz dist:	all cleandist  # validateEnv
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
		if [ -z "$(SUPPRESS_P4_DATA)" ]; then \
			files=$$(cd $(CONTROLLER_deploy_PATH) && p4 files ... | head) ; \
			if [ -n "$$files" ]; then \
				(cd $(CONTROLLER_deploy_PATH) && p4 changes -m 1 ... | cut -d' ' -f2) > $(CONTROLLER_deploy_PATH)/.headrevision ; \
			else \
				cat /dev/null > $(CONTROLLER_deploy_PATH)/.headrevision ; \
			fi ; \
		fi ; \
		tar cpvf - $(binfiles) $(configfile) | (cd $(fulldist) && tar xpvf -) ; \
		tar zcvf $(fulldist).tar.gz $(fulldist) && { echo "Joy ... dist left in "$(fulldist)".tar.gz" ; }
		rm -f latest.tar.gz
		ln -s $(fulldist).tar.gz latest.tar.gz

#		p4 info | $(VERSION_INFO_PROCESSOR) > $(fulldist)/version.dat ; \
#		echo "Change Number: $(distnum)" | $(VERSION_INFO_PROCESSOR) >> $(fulldist)/version.dat ; \
#		tar zcvf $(fulldist).tar.gz $(fulldist) && { echo "Joy ... dist left in "$(fulldist)".tar.gz" ; }

cleandist	:;	rm -rf $(fulldist)

deployCmd	= ssh $(SSH_EXTRAS) -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey -l $(destUser) $(destHost)

deploy ::	$(fulldist).tar.gz
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
