use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'XML::Grammar::Screenplay',
    license             => 'bsd',
    dist_author         => 'Shlomi Fish <shlomif@cpan.org>',
    dist_version_from   => 'lib/XML/Grammar/Screenplay.pm',
    build_requires => {
        'Test::More' => 0,
        'Class::Accessor' => 0,
        'XML::Writer' => 0,
    },
    add_to_cleanup      => [ 'XML-Grammar-Screeplay-*' ],
);

$builder->create_build_script();
