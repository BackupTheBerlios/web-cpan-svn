#!/usr/bin/perl 

use strict;
use warnings;

=head1 NAME

collect-mailing-lists.pl - collect the mailing lists entries from
the Perl 5 Wiki into one database.

=cut

use WWW::Mechanize;
use HTML::TreeBuilder::LibXML;
use Data::Dumper;

my $mech = WWW::Mechanize->new();

$mech->get("http://www.perlfoundation.org/perl5/index.cgi?mailing_lists");

my $prefix = "http://www.perlfoundation.org/perl5/index.cgi?";
my $links = $mech->find_all_links(
    url_abs_regex => qr{\A\Q$prefix\E},
);

my @valid_links = 
(
    grep 
    {
        my $url = $_->url_abs();
        (
            $url !~ m{\?(?:mailing_lists\#|lost_mailing_lists|\z|action=|about_this_website|help_section|wiki_(?:news|tools)|policies_and_guidelines|most_wanted_pages|sidebar|perl_5_wiki)}
        );
    }
    @$links
);

my %visited_links;
LINKS_LOOP:
foreach my $l (@valid_links)
{
    my $url = $l->url_abs();

    if ($visited_links{$url}++)
    {
        next LINKS_LOOP;
    }
    print "Visiting $url\n";
    $mech->get($l->url());

    my $content = $mech->response->content();

    my $tree = HTML::TreeBuilder::LibXML->new;
    $tree->parse($content);
    $tree->eof;

    my ($mailing_list_ul) = $tree->findnodes(
        q{//h2/a[contains(@href, "mailing_lists")]/following::ul}
    );

    if (!defined($mailing_list_ul))
    {
        die "Cannot find in {{ $url }}!";
    }

    my @mailing_lists = $mailing_list_ul->findnodes("li");

    foreach my $mail_list (@mailing_lists)
    {
        my $text = $mail_list->as_HTML();

        my $desc;
        if (! (($desc) = $text =~ m{<li>(.*?)</li>}))
        {
            die "Could not find description.";
        }

        print "DESC == $desc\n";

        my ($mail_list_ul) = $mail_list->findnodes("following-sibling::ul");

        my @items = $mail_list_ul->findnodes("li");

        foreach my $item (@items)
        {
            my ($key) = ($item->as_HTML() =~ m{\A<li>([^<]+)<});
            my ($value_a_tag) = $item->findnodes("a");
            my ($value_url, $value_content);

            if (!defined($value_a_tag))
            {
                $value_url = "";
                ($key, $value_content) = ($key =~ m{\A([^:]+):.*?\z}ms);
            }
            else
            {
                $value_url = $value_a_tag->attr("href");
                $value_content = $value_a_tag->as_text();
            }

            print "------------------------\n";
            print "\tKey == $key\n",
                "\tValue-url == $value_url\n", 
                "\tValue-content == $value_content\n"
                ;
        }
    }
}
continue
{
    $mech->back();
}

=head1 LICENSE

This file is licensed under the MIT X11 License:

L<http://www.opensource.org/licenses/mit-license.php>

=cut
