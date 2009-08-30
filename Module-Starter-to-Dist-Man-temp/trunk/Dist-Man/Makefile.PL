# vi:et:sw=4 softtabstop=4
use strict;
use warnings;
use 5.006001;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Dist::Man',
    AUTHOR              => 'Andy Lester <andy@petdance.com>',
    VERSION_FROM        => 'lib/Dist/Man.pm',
    (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
    ABSTRACT_FROM       => 'lib/Dist/Man.pm',
    EXE_FILES           => [ 'bin/pl-dist-man' ],
    PREREQ_PM => {
        'Test::More'            => 0,
        'ExtUtils::Command'     => 0,
        'File::Spec'            => 0,
        'Getopt::Long'          => 0,
        'Pod::Usage'            => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Dist-Man-*' },
);

sub MY::postamble {
    my $postamble = <<'MAKE_FRAG';
.PHONY: tags critic

tags:
	ctags -f tags --recurse --totals \
		--exclude=blib \
		--exclude=.svn \
		--exclude='*~' \
		--languages=Perl --langmap=Perl:+.t \

critic:
	perlcritic -verbose "%f: [%p] %m at line %l, near '%r'.  (Severity: %s)\n" -q -profile perlcriticrc lib/ bin/ t/
MAKE_FRAG

    return $postamble;
}
