use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder;

my $builder = Test::Run::Builder->new(
    module_name         => 'Term::Eatline',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@cpan.org>',
    dist_version_from   => 'lib/Term/Eatline.pm',
    build_requires =>
    {
        'Expect' => 0,
        'Test::More' => 0,
    },
    requires =>
    {
        'Carp' => 0,
        'Class::Accessor' => 0,
        'Curses' => 0,
        'File::Spec' => 0,
        'List::Util' => 0,
    },
    add_to_cleanup      => [ 'Term-Eatline-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
