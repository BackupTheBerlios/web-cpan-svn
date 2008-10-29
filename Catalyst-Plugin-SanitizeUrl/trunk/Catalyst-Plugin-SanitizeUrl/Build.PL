use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    'module_name' => "Catalyst::Plugin::SanitizeUrl",
    'requires' =>
    {
        Catalyst => '5.23',
    },
    build_requires =>
    {
        'Test::More' => 0,
    },
    'license' => "perl",
    create_makefile_pl => 'traditional',
);

$build->create_build_script;
