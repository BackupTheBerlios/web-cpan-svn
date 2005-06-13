use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'PerlPoint::Converters::Xhtml',
    AUTHOR              => 'Shlomi Fish <shlomif@iglu.org.il>',
    VERSION_FROM        => 'lib/PerlPoint/Converters/Xhtml.pm',
    ABSTRACT_FROM       => 'lib/PerlPoint/Converters/Xhtml.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    EXE_FILES => [ "pp2xhtml" ],
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'PerlPoint-Converters-Xhtml-*' },
);
