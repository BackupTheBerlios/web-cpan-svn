use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'WWW::BooksTracker',
    VERSION_FROM => 'lib/WWW/BooksTracker.pm',
    PREREQ_PM    => { Catalyst => 5 },
    test         => { TESTS => join ' ', ( glob('t/*.t'), glob('t/*/*.t') ) }
);

