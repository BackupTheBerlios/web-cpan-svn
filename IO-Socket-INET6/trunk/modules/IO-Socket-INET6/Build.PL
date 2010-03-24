use strict;
use warnings;

use lib "./inc";

use Test::Run::Builder;

my $build = Test::Run::Builder->new(
    'module_name' => "IO::Socket::INET6",
    'requires' => 
    {
        'Carp' => 0,
        'Errno' => 0,
        'Exporter' => 0,
        'IO::Socket' => 0,
        'Socket' => 0,
        'Socket6' => "0.12",
        'strict' => 0,
        'warnings' => 0,
    },
    build_requires =>
    {
        'Test::More' => 0,
    },
    'license' => "perl",
    create_makefile_pl => 'traditional',
);
$build->create_build_script;
