use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::OpenSVN',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    requires => 
    {
        'LWP::UserAgent' => 0,
        'perl' => "5.006",
    },
    build_requires =>
    {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'WWW-OpenSVN-*' ],
    create_makefile_pl => 'traditional',
    meta_add => {
        resources => {
            homepage => "http://web-cpan.berlios.de/modules/WWW-OpenSVN/",
            license => "http://en.wikipedia.org/wiki/MIT_License",
            Repository => "http://svn.berlios.de/svnroot/repos/web-cpan/www-opensvn/",
        },
    },
);

$builder->create_build_script();
