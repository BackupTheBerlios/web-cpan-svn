use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Text::Qantor',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@cpan.org>',
    dist_version_from   => 'lib/Text/Qantor.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Text-Qantor-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
