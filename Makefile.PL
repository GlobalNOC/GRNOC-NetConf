use strict;
use warnings;
use ExtUtils::MakeMaker;


sub MY::postamble { << 'END';}
rpm:    dist
	rpmbuild -ta perl-GRNOC-NetConf-$(VERSION).tar.gz
END

WriteMakefile(
    NAME                => 'perl-GRNOC-NetConf',
    AUTHOR              => 'GRNOC Systems Engineering <syseng@grnoc.iu.edu>',
    VERSION_FROM        => 'lib/GRNOC/NetConf/Device.pm',
    PL_FILES            => {},
    PREREQ_PM => {
    'Net::SSH2' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'perl-NetConf-*' },
);

sub MY::test {
    q(
TEST_VERBOSE=1
test : pure_all
	$(FULLPERL) t/TEST $(TEST_VERBOSE)

test_jenkins : pure_all
	$(FULLPERL) t/TEST $(TEST_VERBOSE) --formatter=TAP::Formatter::Console

    );
}
