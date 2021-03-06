# $Id: RSS.pm 1934 2006-04-22 05:13:55Z btrott $

package XML::Feed::RSS;
use strict;

use base qw( XML::Feed );
use DateTime::Format::Mail;
use DateTime::Format::W3CDTF;

our $PREFERRED_PARSER = "XML::RSS";

sub init_empty {
    my $feed = shift;
    eval "use $PREFERRED_PARSER"; die $@ if $@;
    $feed->{rss} = $PREFERRED_PARSER->new( version => '2.0' );
    $feed->{rss}->add_module(prefix => "content", uri => 'http://purl.org/rss/1.0/modules/content/');
    $feed->{rss}->add_module(prefix => "dcterms", uri => 'http://purl.org/dc/terms/');
    $feed->{rss}->add_module(prefix => "atom", uri => 'http://www.w3.org/2005/Atom');
    $feed;
}

sub init_string {
    my $feed = shift;
    my($str) = @_;
    $feed->init_empty;
    if ($str) {
        $feed->{rss}->parse($$str);
    }
    $feed;
}

sub format { 'RSS ' . $_[0]->{rss}->{'version'} }

## The following elements are the same in all versions of RSS.
sub title       { shift->{rss}->channel('title', @_) }
sub link        { shift->{rss}->channel('link', @_) }
sub description { shift->{rss}->channel('description', @_) }

## This is RSS 2.0 only--what's the equivalent in RSS 1.0?
sub copyright   { shift->{rss}->channel('copyright', @_) }

## The following all work transparently in any RSS version.
sub language {
    my $feed = shift;
    if (@_) {
        $feed->{rss}->channel('language', $_[0]);
        $feed->{rss}->channel->{dc}{language} = $_[0];
    } else {
        $feed->{rss}->channel('language') ||
        $feed->{rss}->channel->{dc}{language};
    }
}

sub self_link {
    my $feed = shift;

    if (@_) {
        my $uri = shift;

        $feed->{rss}->channel->{'atom'}{'link'} =
        {
            rel => "self",
            href => $uri,
            type => "application/rss+xml",
        };
    }

    return $feed->{rss}->channel->{'atom'}{'link'};
}

sub generator {
    my $feed = shift;
    if (@_) {
        $feed->{rss}->channel('generator', $_[0]);
        $feed->{rss}->channel->{'http://webns.net/mvcb/'}{generatorAgent} =
            $_[0];
    } else {
        $feed->{rss}->channel('generator') ||
        $feed->{rss}->channel->{'http://webns.net/mvcb/'}{generatorAgent};
    }
}

sub author {
    my $feed = shift;
    if (@_) {
        $feed->{rss}->channel('webMaster', $_[0]);
        $feed->{rss}->channel->{dc}{creator} = $_[0];
    } else {
        $feed->{rss}->channel('webMaster') ||
        $feed->{rss}->channel->{dc}{creator};
    }
}

sub modified {
    my $rss = shift->{rss};
    if (@_) {
        $rss->channel('pubDate',
            DateTime::Format::Mail->format_datetime($_[0]));
        ## XML::RSS is so weird... if I set this, it will try to use
        ## the value for the lastBuildDate, which I don't want--because
        ## this date is formatted for an RSS 1.0 feed. So it's commented out.
        #$rss->channel->{dc}{date} =
        #    DateTime::Format::W3CDTF->format_datetime($_[0]);
    } else {
        my $date;
        eval {
            if (my $ts = $rss->channel('pubDate')) {
                $date = DateTime::Format::Mail->parse_datetime($ts);
            } elsif ($ts = $rss->channel->{dc}{date}) {
                $date = DateTime::Format::W3CDTF->parse_datetime($ts);
            }
        };
        return $date;
    }
}

sub entries {
    my $rss = $_[0]->{rss};
    my @entries;
    for my $item (@{ $rss->{items} }) {
        push @entries, XML::Feed::Entry::RSS->wrap($item);
    }
    @entries;
}

sub add_entry {
    my $feed = shift;
    my($entry) = @_;
    $feed->{rss}->add_item(%{ $entry->unwrap });
}

sub as_xml { $_[0]->{rss}->as_string }

package XML::Feed::Entry::RSS;
use strict;

use XML::Feed::Content;

use base qw( XML::Feed::Entry );

sub init_empty { $_[0]->{entry} = { } }

sub title {
    my $entry = shift;
    @_ ? $entry->{entry}{title} = $_[0] : $entry->{entry}{title};
}

sub link {
    my $entry = shift;
    if (@_) {
        $entry->{entry}{link} = $_[0];
        ## For RSS 2.0 output from XML::RSS. Sigh.
        $entry->{entry}{permaLink} = $_[0];
    } else {
        $entry->{entry}{link} || $entry->{entry}{guid};
    }
}

sub summary {
    my $item = shift->{entry};
    if (@_) {
        $item->{description} = ref($_[0]) eq 'XML::Feed::Content' ?
            $_[0]->body : $_[0];
        ## Because of the logic below, we need to add some dummy content,
        ## so that we'll properly recognize the description we enter as
        ## the summary.
        if (!$item->{content}{encoded} &&
            !$item->{'http://www.w3.org/1999/xhtml'}{body}) {
            $item->{content}{encoded} = ' ';
        }
    } else {
        ## Some RSS feeds use <description> for a summary, and some use it
        ## for the full content. Pretty gross. We don't want to return the
        ## full content if the caller expects a summary, so the heuristic is:
        ## if the <entry> contains both a <description> and one of the elements
        ## typically used for the full content, use <description> as summary.
        my $txt;
        if ($item->{description} &&
            ($item->{content}{encoded} ||
             $item->{'http://www.w3.org/1999/xhtml'}{body})) {
            $txt = $item->{description};
        }
        XML::Feed::Content->wrap({ type => 'text/plain', body => $txt });
    }
}

sub content {
    my $item = shift->{entry};
    if (@_) {
        my $c = ref($_[0]) eq 'XML::Feed::Content' ? $_[0]->body : $_[0];
        $item->{content}{encoded} = $c;
    } else {
        my $body =
            $item->{content}{encoded} ||
            $item->{'http://www.w3.org/1999/xhtml'}{body} ||
            $item->{description};
        XML::Feed::Content->wrap({ type => 'text/html', body => $body });
    }
}

sub category {
    my $item = shift->{entry};
    if (@_) {
        $item->{category} = $item->{dc}{subject} = $_[0];
    } else {
        $item->{category} || $item->{dc}{subject};
    }
}

sub author {
    my $item = shift->{entry};
    if (@_) {
        $item->{author} = $item->{dc}{creator} = $_[0];
    } else {
        $item->{author} || $item->{dc}{creator};
    }
}

## XML::RSS doesn't give us access to the rdf:about for the <item>,
## so we have to fall back to the <link> element in RSS 1.0 feeds.
sub id {
    my $item = shift->{entry};
    if (@_) {
        $item->{guid} = $_[0];
    } else {
        $item->{guid} || $item->{link};
    }
}

sub issued {
    my $item = shift->{entry};
    if (@_) {
        $item->{dc}{date} = DateTime::Format::W3CDTF->format_datetime($_[0]);
        $item->{pubDate} = DateTime::Format::Mail->format_datetime($_[0]);
    } else {
        ## Either of these could die if the format is invalid.
        my $date;
        eval {
            if (my $ts = $item->{pubDate}) {
                my $parser = DateTime::Format::Mail->new;
                $parser->loose;
                $date = $parser->parse_datetime($ts);
            } elsif ($ts = $item->{dc}{date}) {
                $date = DateTime::Format::W3CDTF->parse_datetime($ts);
            }
        };
        return $date;
    }
}

sub modified {
    my $item = shift->{entry};
    if (@_) {
        $item->{dcterms}{modified} =
            DateTime::Format::W3CDTF->format_datetime($_[0]);
    } else {
        if (my $ts = $item->{dcterms}{modified}) {
            return eval { DateTime::Format::W3CDTF->parse_datetime($ts) };
        }
    }
}

1;
