# $Id: Entry.pm 1872 2005-08-12 04:28:42Z btrott $

package XML::Feed::Entry;
use strict;
use base qw( Class::ErrorHandler );

use Carp;

sub wrap {
    my $class = shift;
    my($item) = @_;
    bless { entry => $item }, $class;
}

sub unwrap { $_[0]->{entry} }

sub new {
    my $class = shift;
    my($format) = @_;
    $format ||= 'Atom';
    my $format_class = 'XML::Feed::' . $format;
    eval "use $format_class";
    Carp::croak("Unsupported format $format: $@") if $@;
    my $entry = bless {}, join('::', __PACKAGE__, $format);
    $entry->init_empty or return $class->error($entry->errstr);
    $entry;
}

sub init_empty { 1 }

sub convert {
    my $entry = shift;
    my($format) = @_;
    my $new = __PACKAGE__->new($format);
    for my $field (qw( title link content summary category author id issued modified )) {
        my $val = $entry->$field();
        next unless defined $val;
        $new->$field($val);
    }
    $new;
}

sub title;
sub link;
sub content;
sub summary;
sub category;
sub author;
sub id;
sub issued;
sub modified;

1;
__END__

=head1 NAME

XML::Feed::Entry - Entry/item in a syndication feed

=head1 SYNOPSIS

    ## $feed is an XML::Feed object.
    for my $entry ($feed->entries) {
        print $entry->title, "\n", $entry->summary, "\n\n";
    }

=head1 DESCRIPTION

I<XML::Feed::Entry> represents an entry/item in an I<XML::Feed> syndication
feed.

=head1 USAGE

=head2 XML::Feed::Entry->new($format)

Creates a new I<XML::Feed::Entry> object in the format I<$format>, which
should be either I<RSS> or I<Atom>.

=head2 $entry->convert($format)

Converts the I<XML::Feed::Entry> object into the I<$format> format, and
returns the new object.

=head2 $entry->title([ $title ])

The title of the entry.

=head2 $entry->link([ $uri ])

The permalink of the entry, in most cases, except in cases where it points
instead to an offsite URI referenced in the entry.

=head2 $entry->content([ $content ])

Bn I<XML::Feed::Content> object representing the full entry body, or as
much as is available in the feed.

In RSS feeds, this method will look first for
I<http://purl.org/rss/1.0/modules/content/#encoded> and
I<http://www.w3.org/1999/xhtml#body> elements, then fall back to a
I<E<lt>descriptionE<gt>> element.

=head2 $entry->summary([ $summary ])

An I<XML::Feed::Content> object representing a short summary of the entry.
Possibly.

Since RSS feeds do not have the idea of a summary separate from the entry
body, this may not always be what you want. If the entry contains both a
I<E<lt>descriptionE<gt>> element B<and> another element typically used for
the full content of the entry--either I<http://www.w3.org/1999/xhtml/body>
or I<http://purl.org/rss/1.0/modules/content/#encoded>--we treat that as
the summary. Otherwise, we assume that there isn't a summary, and return
an I<XML::Feed::Content> object with an empty string in the I<body>.

=head2 $entry->category([ $category ])

The category in which the entry was posted.

=head2 $entry->author([ $author ])

The name or email address of the person who posted the entry.

=head2 $entry->id([ $id ])

The unique ID of the entry.

=head2 $entry->issued([ $issued ])

A I<DateTime> object representing the date and time at which the entry
was posted.

If present, I<$issued> should be a I<DateTime> object.

=head2 $entry->modified([ $modified ])

A I<DateTime> object representing the last-modified date of the entry.

If present, I<$modified> should be a I<DateTime> object.

=head1 AUTHOR & COPYRIGHT

Please see the I<XML::Feed> manpage for author, copyright, and license
information.

=cut
