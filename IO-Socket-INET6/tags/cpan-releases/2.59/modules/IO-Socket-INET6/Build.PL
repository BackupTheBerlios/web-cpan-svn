use strict;

use Module::Build;

my $build = Module::Build->new(
    'module_name' => "IO::Socket::INET6",
    'requires' => 
    {
        'IO::Socket' => 0,
        'Socket6' => "0.12",
    },
    build_requires =>
    {
        'Test::More' => 0,
    },
    'license' => "perl",
    create_makefile_pl => 'traditional',
);
$build->create_build_script;
