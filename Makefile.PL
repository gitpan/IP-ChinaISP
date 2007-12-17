use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'IP::ChinaISP',
    AUTHOR              => 'Jeff Pang <pangj@earthlink.net>',
    VERSION_FROM        => 'lib/IP/ChinaISP.pm',
    ABSTRACT_FROM       => 'lib/IP/ChinaISP.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'IP-ChinaISP-*' },
);
