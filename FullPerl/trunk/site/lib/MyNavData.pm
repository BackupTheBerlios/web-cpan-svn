package MyNavData;

use strict;
use warnings;

use MyManageNews;

my $hosts =
{
    'mysite' =>
    {
        'base_url' => "http://myhost.mydomain/",
    },
};

my $news_manager = get_news_manager();

sub get_news_category
{
    my $items = $news_manager->get_navmenu_items('num_items' => 5);
    if (@$items)
    {
        return
        {
            'text' => "News",
            'url' => "news/",
            'subs' =>
            [
                @$items,
            ],
        },
    }
    else
    {
        return ();
    }
}

my $tree_contents =
{
    'host' => "mysite",
    'text' => "My Site",
    'title' => "My Site",
    'subs' =>
    [
        {
            'text' => "Home",
            'url' => "",
        },
        {
            'text' => "About",
            'url' => "about.html",
        },
        get_news_category(),
        {
            'text' => "Documents",
            'url' => "docs/",
            'expand' => { 'bool' => 1, },
            'subs' =>
            [
                {
                    'url' => "docs/spec/",
                    'text' => "Spec",
                    'title' => "Specifications",
                },
            ],
        },
        {
            'text' => "Links",
            'url' => "links/",
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
