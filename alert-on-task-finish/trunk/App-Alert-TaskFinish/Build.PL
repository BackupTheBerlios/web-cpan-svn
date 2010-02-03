use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::Alert::TaskFinish',
    license             => 'mit',
    dist_author         => q{Shlomi Fish <shlomif@iglu.org.il>},
    dist_version_from   => 'lib/App/Alert/TaskFinish.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'App-Alert-TaskFinish-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
