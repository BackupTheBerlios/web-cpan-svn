package MyModulesList;

use strict;

my @modules_list =
(
    {
        'perl_name' => "HTML-Strip-Whitespace",
        'text' => "Strip Whitespace",
        'title' => "Strip Unnecessary Whitespace from HTML",
    },
    {
        'perl_name' => "HTML-Widgets-NavMenu",
        'text' => "Navigation Menu",
        'title' => "Generate Navigation Menus",
    },
    {
        'perl_name' => "SVN-RaWeb-Light",
        'text' => "Light SVN Interface",
        'title' => "A Lightweight Web-based Subversion Interface",
    },
    {
        'perl_name' => "WWW-Form",
        'text' => "WWW::Form",
        'title' => "Manage Forms Flow Using Perl",
    },
);

sub get_module_list
{
    return \@modules_list,
}

1;


