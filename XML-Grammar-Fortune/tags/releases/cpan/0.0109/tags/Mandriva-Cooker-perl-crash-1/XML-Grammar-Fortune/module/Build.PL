use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder;

my $builder = Test::Run::Builder->new(
    module_name         => 'XML::Grammar::Fortune',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/XML/Grammar/Fortune.pm',
    requires => {
        'Class::Accessor' => 0,
        'File::Spec' => 0,
        'vars' => 0,
        'warnings' => 0,
        'Text::Format' => 0,
        'XML::LibXML' => 0,
        'XML::LibXSLT' => 0,
    },
    build_requires =>
    {
        'IO::String' => 0,
        'Test::Differences' => 0,
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'XML-Grammar-Fortune-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
