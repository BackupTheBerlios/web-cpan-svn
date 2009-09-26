use strict;
use warnings;

use lib "./inc";

use Test::Run::Builder;

my $builder = Test::Run::Builder->new(
    module_name         => 'XML::GrammarBase',
    license             => 'mit',
    dist_author         => q{Shlomi Fish <shlomif@cpan.org>},
    dist_version_from   => 'lib/XML/GrammarBase.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'XML-GrammarBase-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
