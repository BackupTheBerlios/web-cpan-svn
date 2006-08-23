package MyNavData;

use strict;

use MyModulesList;

my $hosts =
{
    'berlios' => 
    {
        'base_url' => "http://web-cpan.berlios.de/",
    },
};

sub generate_module_nav_menu_entry
{
    my $module_entry = shift;
    return
        +{
            'url' => "modules/". $module_entry->{'perl_name'} . "/",
            'text' => $module_entry->{'text'},
            'title' => $module_entry->{'title'},
        };
}

my $tree_contents =
{
    'host' => "berlios",
    'text' => "Web-CPAN",
    'title' => "A Berlios Hub for Development of CPAN Modules",
    'subs' =>
    [
        {
            'text' => "Home",
            'url' => "",
        },
        {
            'text' => "Modules",
            'url' => "modules/",
            'expand' => { 'bool' => 1, },
            'subs' =>
            [
                (map { generate_module_nav_menu_entry($_) }
                    @{MyModulesList::get_module_list()}),
            ],
        },
        {
            'text' => "Get T-Shirts!",
            'url' => "offers/o-and-m-2006-08/",
            'title' => ("Hack on Web-CPAN and get " . 
                "an &quot;Ozy and Millie&quot; T-Shirt"),
        },
    ],
};

sub get_params
{
    return 
        (
            'hosts' => $hosts,
            'tree_contents' => $tree_contents,
        );
}

1;
