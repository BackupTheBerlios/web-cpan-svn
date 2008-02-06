use strict;

use Module::Build;

my $build = Module::Build->new(
    'module_name' => "IO::Socket::INET6",
    'requires' => 
    {
        'Socket6' => "0.12",
    },
    'license' => "perl",
    create_makefile_pl => 'traditional',
);
$build->create_build_script;
