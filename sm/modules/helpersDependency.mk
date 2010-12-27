

# #
# # "Helpers" are compiler libraries. Sometimes they change
# # but they are in a different directory. The suffix rules
# # don't track these by default (they are themselves generated)
# # so, this lib provides the function necessary to update all
# # generated scripts (built scripts) if a dependent "Helper"
# # library changes.
# # 

# shellHelpers	=		$(shell grep -l shellHelpers *.m80)
# shellHelperDependencies	=	$(patsubst %.m80,%,$(shellHelpers))
# $(shellHelperDependencies) : $(LIB_deploy_PATH)/perl/Helpers/shellHelpers.pm


# # test_shellHelpers :; echo $(shellHelperDependencies)

# sshHelpers	=		$(shell grep -l sshHelpers *.m80)
# sshHelperDependencies	=	$(patsubst %.m80,%,$(sshHelpers))
# $(sshHelperDependencies) : $(LIB_deploy_PATH)/perl/Helpers/sshHelpers.pm

# moduleHelpers	=		$(shell grep -l moduleHelpers *.m80)
# moduleHelperDependencies=	$(patsubst %.m80,%,$(moduleHelpers))
# $(moduleHelperDependencies) : $(CONTROLLER_deploy_PATH)/utils/moduleHelpers.pm


# # test_moduleHelpers :; echo $(moduleHelperDependencies)

