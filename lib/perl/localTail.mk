tags    ::
# 	etags -r '/.*{n => [a-zA-Z0-9_]*/' $$(m80 --dump | grep _SRC_DIR | cut -d= -f2 | awk '{print $$0 "/module.xml.m80"}')
#         @echo Left tags file for modules in $$(pwd)/TAGS.
#         @echo load into emacs with \(visit-tags-file\)
	etags -r '/^sub [a-zA-Z0-9_]*/' $$(find . | grep \.m80$)

