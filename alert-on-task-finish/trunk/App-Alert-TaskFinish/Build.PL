use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::Alert::TaskFinish',
    license             => 'mit',
    dist_author         => q{Shlomi Fish <shlomif@cpan.org>},
    dist_version_from   => 'lib/App/Alert/TaskFinish.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'App-Alert-TaskFinish-*' ],
    create_makefile_pl => 'traditional',
    script_files =>
    [qw(
        scripts/finish-client
        scripts/finish-cue
        scripts/finish-server
    )],
);

$builder->create_build_script();
