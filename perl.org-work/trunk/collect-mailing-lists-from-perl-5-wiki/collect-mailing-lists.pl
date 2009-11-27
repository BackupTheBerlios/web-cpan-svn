#!/usr/bin/perl 

use strict;
use warnings;

use Common;

=head1 NAME

collect-mailing-lists.pl - collect the mailing lists entries from
the Perl 5 Wiki into one database.

=cut

use WWW::Mechanize;
use HTML::TreeBuilder::LibXML;
use Data::Dumper;
use YAML::XS qw(LoadFile DumpFile);

my $mech = WWW::Mechanize->new();

$mech->get("http://www.perlfoundation.org/perl5/index.cgi?mailing_lists");

my $prefix = "http://www.perlfoundation.org/perl5/index.cgi?";
my $links = $mech->find_all_links(
    url_abs_regex => qr{\A\Q$prefix\E},
);

my $content = $mech->response()->content();

my $start =qq{<h2 id="categories">Categories</h2>};
my $end = qq{<h2 id="end_of_categories_marker_for_processing">End of Categories (Marker for Processing)</h2>};

my %canonical_keys = 
(
    'Archive[s]' => "archives",
    'Archive' => "archives",
    'Mail-Archive Archive[s]' => "mail_archive",
    "Comments" => "comments",
    'Help' => "help",
    "Homepage" => "homepage",
    'Name' => "basename",
    'NNTP Archive' => "nntp_archive_url",
    'RSS RDF Feed' => "rss_rdf_feed_url",
    "Subscribe" => "subscribe",
    "Subscribe/Unsubscribe/Set Options" => "all_in_one_ml_settings",
    "Unsubscribe" => "unsubscribe",
);

my ($catlinks) = ($content =~ m{\Q$start\E(.*?)\Q$end\E}ms);

my @valid_links = 
(
    grep
    {
        my $rel_url = $_->url();

        (index($catlinks, qq{"$rel_url"}) >= 0)
    }
    grep 
    {
        my $url = $_->url_abs();
        (
            $url !~ m{\?(?:activestate|cpants\z|windows\z|usenet\z|books\z|unix|corba|eureka|linux|damian_conway|mark_jason_dominus|mailing_lists(?:\#|_\d)|lost_mailing_lists|\z|action=|about_this_website|help_section|wiki_(?:news|tools)|policies_and_guidelines|most_wanted_pages|sidebar|perl_5_wiki)}
        );
    }
    @$links
);

my $yaml_fn = Common::get_yaml_fn();

if (! -e $yaml_fn)
{
    DumpFile($yaml_fn, {});
}

my $visited_links = LoadFile($yaml_fn);

eval {
LINKS_LOOP:
foreach my $l (@valid_links)
{
    my $process_link = sub {
    my $url = $l->url_abs();

    my $url_entry = ($visited_links->{$url} ||= { count => 0 });
    if ($url_entry->{count})
    {
        return;
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

    my @mailing_lists_out;

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

        my @items_out;

        foreach my $item (@items)
        {
            my ($key) = ($item->as_HTML() =~ m{\A<li>([^<]+)<});
            my ($value_a_tag) = $item->findnodes("a");
            my ($value_url, $value_content, $value_prelude);

            if ($key !~ m{:})
            {
                die qq{No colon (':') in key in item in "$url"!};
            }
            my $split_by_colon = sub { 
                return ($key =~ m{\A([^:]+):(.*?)\z}ms);
            };
            if (!defined($value_a_tag))
            {
                $value_url = "";
                $value_prelude = "";
                ($key, $value_content) = $split_by_colon->();
            }
            else
            {
                $value_url = $value_a_tag->attr("href");
                ($key, $value_prelude) = $split_by_colon->();
                $value_content = $value_a_tag->as_text();
            }

            # Trim the value from leading and trailing whitespace.
            $value_content =~ s{\A\s+}{};
            $value_content =~ s{\s+\z}{};

            $key =~ s{:\s*\z}{};

            print "------------------------\n";
            print "\tKey == $key\n",
                "\tValue-url == $value_url\n", 
                "\tValue-content == $value_content\n"
                ;

            my $canon_key;

            if (!defined($canon_key = $canonical_keys{$key}))
            {
                die "Could not find Canonical key for '$key'!";
            }

            push @items_out,
                +{
                    key => $key,
                    value_url => $value_url,
                    value_content => $value_content,
                    value_prelude => $value_prelude,
                    canon_key => $canon_key,
                }
            ;
        }

        push @mailing_lists_out,
            +{
                desc => $desc,
                items => \@items_out,
            }
            ;
    }

    $url_entry->{mailing_lists} = \@mailing_lists_out;
    $url_entry->{count} = 1;

    };

    $process_link->();
}
continue
{
    $mech->back();
}

};

my $err = $@;

DumpFile($yaml_fn, $visited_links);

if ($err)
{
    die $err;
}

=head1 LICENSE

This file is licensed under the MIT X11 License:

L<http://www.opensource.org/licenses/mit-license.php>

=cut

1;

