package MyManageNews;

use base 'Exporter';

our @EXPORT=(qw(get_news_manager));

use strict;
use warnings;

use HTML::Latemp::News;

my @news_items =
(
    (map 
        { 
            +{%$_, 
                'author' => "Shlomi Fish", 
                'category' => "My Site Category", 
            }
        }
        (
            # TODO: Fill Items Here.
        ),
    )
);

sub gen_news_manager
{
    return
        HTML::Latemp::News->new(
            'news_items' => \@news_items,
            'title' => "My Site News",
            'link' => "http://www.link-to-my-site.tld/",
            'language' => "en-US",
            'copyright' => "Copyright by Shlomi Fish, (c) 2005",
            'webmaster' => "Shlomi Fish <author\@domain.org>",
            'managing_editor' => "Shlomi Fish <author\@domain.org>",
            'description' => "News of the My Site",
        );
}

# A singleton.
{
    my $news_manager;

    sub get_news_manager
    {
        if (!defined($news_manager))
        {
            $news_manager = gen_news_manager();
        }
        return $news_manager;
    }
}

1;
