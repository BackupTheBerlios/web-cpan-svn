use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    'module_name' => "HTML::Strip::Whitespace",
    'requires' => 
    {
           'HTML::TokeParser::Simple' => 0,
           'warnings' => 0,
           'strict' => 0,
           'Exporter' => 0,
           'vars' => 0,
    },
    'build_requires' =>
    {
        'Test::More' => 0,
    },
    'license' => "mit",
    create_makefile_pl => 'traditional',
);
$build->create_build_script;
