use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Plugin::SanitizeUrl',
    AUTHOR    => 'Shlomi Fish (shlomif@iglu.org.il',
    PREREQ_PM => {
        Catalyst            => '5.23',
    },
    VERSION_FROM => 'lib/Catalyst/Plugin/SanitizeUrl.pm'
);

