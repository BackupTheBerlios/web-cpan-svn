use strict;
use warnings;
use Module::Build;

sub tt_inc
{
    return "/usr/share/perl5/data/modules/CGI-Application-NetNewsIface/";
}

my $builder = Module::Build->new(
    module_name         => 'CGI::Application::NetNewsIface',
    license             => 'bsd',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/CGI/Application/NetNewsIface.pm',
    requires => {
        'Test::More' => 0,
        'CGI::Application' => 0,
        'Net::NNTP' => 0,
        'Class::Accessor' => 0,
        'CGI::Application::Plugin::TT' => 0,
    },
    add_to_cleanup      => [ 'CGI-Application-NetNewsIface-*' ],
    create_makefile_pl => 'passthrough',
    install_path => 
    {
        templates => tt_inc(),
    },
    templates_files => {
        map { $_ => $_ } glob("templates/*.tt"),
    },
);

$builder->add_build_element('templates');
$builder->config_data('templates_install_path' => [tt_inc()]);

$builder->create_build_script();


