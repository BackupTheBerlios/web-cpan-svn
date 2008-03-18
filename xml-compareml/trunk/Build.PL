use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'XML::CompareML',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    requires => {
        'Class::Accessor' => 0,
        'XML::LibXML' => 0,
        'XML::LibXML::Common' => 0,
        'CGI' => 0,
        'strict' => 0,
        'warnings' => 0,
    },
    build_requires => {
        'Test::More' => 0,
        'IO::Scalar' => 0,
    },
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
