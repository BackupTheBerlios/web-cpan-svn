use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WWW::OpenSVN',
    AUTHOR              => 'Shlomi Fish <shlomif@iglu.org.il>',
    VERSION_FROM        => 'lib/WWW/OpenSVN.pm',
    ABSTRACT_FROM       => 'lib/WWW/OpenSVN.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'LWP' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-OpenSVN-*' },
);

