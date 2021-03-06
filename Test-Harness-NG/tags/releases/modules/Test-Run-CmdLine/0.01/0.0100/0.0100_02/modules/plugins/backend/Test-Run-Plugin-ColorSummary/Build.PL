use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Test::Run::Plugin::ColorSummary',
    license             => 'BSD',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/Test/Run/Plugin/ColorSummary.pm',
    requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Test-Run-Plugin-ColorSummary-*' ],
);

$builder->create_build_script();
