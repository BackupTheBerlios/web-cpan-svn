use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Term::Eatline',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@cpan.org>',
    dist_version_from   => 'lib/Term/Eatline.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Term-Eatline-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
