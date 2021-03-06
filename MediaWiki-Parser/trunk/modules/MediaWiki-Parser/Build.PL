use strict;
use warnings;
use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder;


my $builder = Test::Run::Builder->new(
    module_name         => 'MediaWiki::Parser',
    license             => 'perl',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/MediaWiki/Parser.pm',
    requires =>
    {
        'Moose' => 0,
        'Exception::Class' => 0,
    },
    build_requires => {
        'Test::More' => 0,
        'Test::Differences' => 0,
    },
    add_to_cleanup      => [ 'MediaWiki-Parser-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
