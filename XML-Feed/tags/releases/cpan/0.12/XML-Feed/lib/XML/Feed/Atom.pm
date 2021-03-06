# $Id: Atom.pm 1958 2006-08-14 05:31:27Z btrott $

package XML::Feed::Atom;
use strict;

use base qw( XML::Feed );
use XML::Atom::Feed;
use XML::Atom::Util qw( iso2dt );
use List::Util qw( first );
use DateTime::Format::W3CDTF;

sub init_empty {
    my $feed = shift;
    $feed->{atom} = XML::Atom::Feed->new(Version => 1.0);
    $feed;
}

sub init_string {
    my $feed = shift;
    my($str) = @_;
    if ($str) {
        $feed->{atom} = XML::Atom::Feed->new(Stream => $str)
            or return $feed->error(XML::Atom::Feed->errstr);
    }
    $feed;
}

sub format { 'Atom' }

sub title { shift->{atom}->title(@_) }
sub link {
    my $feed = shift;
    if (@_) {
        $feed->{atom}->add_link({ rel => 'alternate', href => $_[0],
                                  type => 'text/html', });
    } else {
        my $l = first { !defined $_->rel || $_->rel eq 'alternate' } $feed->{atom}->link;
        $l ? $l->href : undef;
    }
}
sub description { shift->{atom}->tagline(@_) }
sub copyright   { shift->{atom}->copyright(@_) }
sub language    { shift->{atom}->language(@_) }
sub generator   { shift->{atom}->generator(@_) }

sub author {
    my $feed = shift;
    if (@_ && $_[0]) {
        my $person = XML::Atom::Person->new(Version => 1.0);
        $person->name($_[0]);
        $feed->{atom}->author($person);
    } else {
        $feed->{atom}->author ? $feed->{atom}->author->name : undef;
    }
}

sub modified {
    my $feed = shift;
    if (@_) {
        $feed->{atom}->modified(DateTime::Format::W3CDTF->format_datetime($_[0]));
    } else {
        $feed->{atom}->modified ? iso2dt($feed->{atom}->modified) : undef;
    }
}

sub entries {
    my @entries;
    for my $entry ($_[0]->{atom}->entries) {
        push @entries, XML::Feed::Entry::Atom->wrap($entry);
    }

    @entries;
}

sub add_entry {
    my $feed = shift;
    my($entry) = @_;
    $feed->{atom}->add_entry($entry->unwrap);
}

sub as_xml { $_[0]->{atom}->as_xml }

package XML::Feed::Entry::Atom;
use strict;

use base qw( XML::Feed::Entry );
use XML::Atom::Util qw( iso2dt );
use XML::Feed::Content;
use XML::Atom::Entry;
use List::Util qw( first );

sub init_empty {
    my $entry = shift;
    $entry->{entry} = XML::Atom::Entry->new(Version => 1.0);
    1;
}

sub title { shift->{entry}->title(@_) }
sub link {
    my $entry = shift;
    if (@_) {
        $entry->{entry}->add_link({ rel => 'alternate', href => $_[0],
                                    type => 'text/html', });
    } else {
        my $l = first { !defined $_->rel || $_->rel eq 'alternate' } $entry->{entry}->link;
        $l ? $l->href : undef;
    }
}

sub summary {
    my $entry = shift;
    if (@_) {
        $entry->{entry}->summary(ref($_[0]) eq 'XML::Feed::Content' ?
            $_[0]->body : $_[0]);
    } else {
        XML::Feed::Content->wrap({ type => 'html',
                                   body => $entry->{entry}->summary });
    }
}

sub content {
    my $entry = shift;
    if (@_) {
        my %param;
        if (ref($_[0]) eq 'XML::Feed::Content') {
            %param = (Body => $_[0]->body);
        } else {
            %param = (Body => $_[0]);
        }
        $entry->{entry}->content(XML::Atom::Content->new(%param, Version => 1.0));
    } else {
        my $c = $entry->{entry}->content;

        # map Atom types to MIME types
        my $type = $c ? $c->type : undef;
        if ($type) {
            $type = 'text/html'  if $type eq 'xhtml' || $type eq 'html';
            $type = 'text/plain' if $type eq 'text';
        }

        XML::Feed::Content->wrap({ type => $type,
                                   body => $c ? $c->body : undef });
    }
}

sub category {
    my $entry = shift;
    my $ns = XML::Atom::Namespace->new(dc => 'http://purl.org/dc/elements/1.1/');
    if (@_) {
        $entry->{entry}->add_category({ term => $_[0] });
    } else {
        my $category = $entry->{entry}->category;
        $category ? ($category->label || $category->term) : $entry->{entry}->get($ns, 'subject');
    }
}

sub author {
    my $entry = shift;
    if (@_ && $_[0]) {
        my $person = XML::Atom::Person->new(Version => 1.0);
        $person->name($_[0]);
        $entry->{entry}->author($person);
    } else {
        $entry->{entry}->author ? $entry->{entry}->author->name : undef;
    }
}

sub id { shift->{entry}->id(@_) }

sub issued {
    my $entry = shift;
    if (@_) {
        $entry->{entry}->issued(DateTime::Format::W3CDTF->format_datetime($_[0])) if $_[0];
    } else {
        $entry->{entry}->issued ? iso2dt($entry->{entry}->issued) : undef;
    }
}

sub modified {
    my $entry = shift;
    if (@_) {
        $entry->{entry}->modified(DateTime::Format::W3CDTF->format_datetime($_[0])) if $_[0];
    } else {
        $entry->{entry}->modified ? iso2dt($entry->{entry}->modified) : undef;
    }
}

1;
