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
    configure_requires =>
    {
        'Module::Build' => '0.36',
    },
    'license' => "perl",
    create_makefile_pl => 'traditional',
    meta_merge =>
    {
        resources =>
        {
            repository => "http://svn.berlios.de/svnroot/repos/web-cpan/IO-Socket-INET6/",
        },
        keywords =>
        [
            "inet6",
            "input",
            "internet",
            "ipv6",
            "network",
            "networking",
            "output",
            "socket",
            "sockets",
        ],
    },
    
);
$build->create_build_script;
