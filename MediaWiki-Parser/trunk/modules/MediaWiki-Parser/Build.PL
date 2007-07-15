use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'MediaWiki::Parser',
    license             => 'perl',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/MediaWiki/Parser.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'MediaWiki-Parser-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
