use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'HTML::Latemp::GenMakeHelpers',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/HTML/Latemp/GenMakeHelpers.pm',
    requires => {
        'Class::Accessor' => 0,
        'File::Find::Rule' => 0,
        'File::Basename' => 0,
        'warnings' => 0,
        'strict' => 0,
        'base' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'HTML-Latemp-GenMakeHelpers-*' ],
);

$builder->create_build_script();
