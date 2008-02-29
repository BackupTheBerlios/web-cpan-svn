use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'XML::CompareML',
    license             => 'bsd',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    requires => {
        'Test::More' => 0,
        'Class::Accessor' => 0,
        'XML::LibXML' => 0,
        'IO::Scalar' => 0,
    },
);

$builder->create_build_script();
