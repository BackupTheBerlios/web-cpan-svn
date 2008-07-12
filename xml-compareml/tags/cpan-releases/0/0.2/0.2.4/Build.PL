use strict;
use warnings;
use Module::Build;
use File::Find;


sub data_inc
{
    return "/usr/share/perl5/data/modules/XML-Grammar-Screenplay/data";
}

my @extradata_files;

sub filter_files
{
    my $filename = $File::Find::name;
    if ((-f $filename) && ($filename =~ /\.(?:mod|xslt|dtd|ent|cat|jpg|rng|xcf\.bz2)$/))
    {
        push @extradata_files, $filename;
    }
}

find({ wanted => \&filter_files, no_chdir => 1}, "extradata");

my $builder = Module::Build->new(
    module_name         => 'XML::CompareML',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    requires => {
        'Class::Accessor' => 0,
        'XML::LibXSLT' => 0,
        'XML::LibXML' => 0,
        'XML::LibXML::Common' => 0,
        'CGI' => 0,
        'strict' => 0,
        'warnings' => 0,
    },
    build_requires => {
        'Test::More' => 0,
        'IO::Scalar' => 0,
        'Test::Differences' => 0,
    },
    create_makefile_pl => 'passthrough',
    install_path =>
    {
        extradata => data_inc(),
    },
    extradata_files =>
    {
        (map { $_ => $_ } @extradata_files),
    },
    
);


$builder->add_build_element('extradata');
$builder->install_path->{'extradata'} = ($builder->prefix() || "/usr") . "/data/modules/XML-CompareML/data";

$builder->config_data('extradata_install_path' => [$builder->install_path->{'extradata'}]);

$builder->create_build_script();
