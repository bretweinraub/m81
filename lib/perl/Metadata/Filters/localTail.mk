all 	::;	@rm -f AllFilters.pm Filters.pl ;  \
		echo "package Metadata::Filters::AllFilters;" >> AllFilters.pm ; \
		for filter in $$(/bin/ls -1 *.pm.m80 | sed -e 's/.pm.m80//g') ; do \
			echo "use Metadata::Filters::"$$filter";" >> AllFilters.pm ; \
		done ; \
		echo "1;" >> AllFilters.pm ; \
		$(MAKE) Filters.pl

clean	::;	rm -f AllFilters.pm Filters.pl

Filters.pl :	clusterPGgenerator.m80_
