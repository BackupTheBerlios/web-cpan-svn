require 5.005_03;

use ExtUtils::MakeMaker;
use ExtUtils::Command qw( touch rm_f );

use constant FLAG_SKIP_PROVE => "t/SKIP-PROVE";

my %parms = (
    NAME            => "Test::Run",
    VERSION_FROM    => "lib/Test/Run/Core.pm",
    PREREQ_PM       => 
    {
        'Class::Accessor' => 0,
        'File::Spec' => 0.6,
        'Test::Harness' => "2.53",
        'Scalar::Util' => 0,
        'TAPx::Parser' => "0.30",
        'NEXT' => 0,
    },
    INSTALLDIRS     => 'perl',
    clean           => { FILES => join( " ", FLAG_SKIP_PROVE, 'Test-Harness-*', '*~' ) },
);

sub MY::postamble {
    return <<'MAKE_FRAG';
.PHONY: tags

tags:
	ctags -f tags --recurse --totals \
		--exclude=blib/ --exclude=t/lib \
		--exclude=.svn --exclude='*~' \
		--languages=Perl --langmap=Perl:+.t \
MAKE_FRAG
}

WriteMakefile( %parms );
